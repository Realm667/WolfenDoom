#!/usr/bin/env python3
"Inject a grAb chunk into a PNG file"
import struct
import zlib
import argparse
from io import SEEK_SET, SEEK_CUR, SEEK_END
from grab import get_bytes as get_grab_bytes

class PNGFile:
    "PNG file"

    # See https://www.w3.org/TR/1996/REC-png-19961001.html#Structure
    # for more information
    header = b"\x89PNG\r\n\x1A\n"

    def __init__(self):
        self.chunks = []

    def read(self, filename):
        "Read a PNG file into chunks"
        with open(filename, "rb") as file:
            header = file.read(8)
            if header != self.header:
                return
            file.seek(0, SEEK_END)
            file_end = file.tell()
            file.seek(8, SEEK_SET)
            while file.tell() != file_end:
                length = struct.unpack("!I", file.read(4))[0]
                name = file.read(4)
                data = file.read(length)
                file.seek(4, SEEK_CUR)  # Skip CRC
                chunk = PNGChunk(name, data)
                self.chunks.append(chunk)

    def chunk_index(self, name):
        "Get the index of the chunk with the given name"
        for index, chunk in enumerate(self.chunks):
            if chunk.name == name:
                return index
        return -1

    def write(self, filename):
        "Write a PNG file using the existing chunks"
        with open(filename, "wb") as file:
            file.write(self.header)
            for chunk in self.chunks:
                file.write(chunk.get_bytes())

class PNGChunk:
    "PNG Chunk"
    def __init__(self, name, data=None):
        self.name = name
        self.data = data

    def get_bytes(self):
        """
        Get the bytes of this chunk, including the length, name, data, and CRC
        """
        data = self.name
        length = 0
        if self.data is not None:
            length = len(self.data)
            data += self.data
        crc = struct.pack("!I", zlib.crc32(data))
        length = struct.pack("!I", length)
        return length + data + crc

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=
                                     "Generate a grAb chunk, and inject it "
                                     "into the given PNG file")
    parser.add_argument('png', help="The PNG file to inject the grAb chunk "
                                    "into")
    parser.add_argument('x', type=int, help="X (horizontal) offset")
    parser.add_argument('y', type=int, help="Y (vertical) offset")
    args = parser.parse_args()
    grabs = get_grab_bytes(args.x, args.y)
    png = PNGFile()
    png.read(args.png)
    png_grab_index = png.chunk_index(b"grAb")
    if grabs is not None:
        grab_chunk = PNGChunk(b"grAb", grabs)
        png_ihdr_index = png.chunk_index(b"IHDR")
        if png_grab_index != -1:
            # Replace existing grAb chunk
            png.chunks[png_grab_index] = grab_chunk
        else:
            # Inject grAb chunk
            png.chunks.insert(png_ihdr_index + 1, grab_chunk)
    elif png_grab_index >= 0:
        # Remove grAb chunk
        del png.chunks[png_grab_index]
    png.write(args.png)
