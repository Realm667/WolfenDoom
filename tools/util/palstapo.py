#!/usr/bin/env python3
# PalStapo: check palettes of all given PNG arguments
import argparse
import struct
import io

parser = argparse.ArgumentParser(
    description="Ensure all given PNGs' palettes match the first PNG's")
parser.add_argument("first")
parser.add_argument("others", nargs="*")
parsed_args = parser.parse_args()

class PNGChunk:
    def __init__(self, name, length):
        self.name = name
        self.length = length


def get_png_palette_crc(filename):
    def read_png_chunk_info(file):
        chunk_length = struct.unpack(">I", file.read(4))[0]
        chunk_id = file.read(4)
        return PNGChunk(chunk_id, chunk_length)
    with open(filename, "rb") as file:
        if file.read(8) != b"\x89PNG\x0D\x0A\x1A\x0A":
            return "Not a PNG file"
        file.seek(33, io.SEEK_SET) # Magic identifer + IHDR chunk
        cur_chunk = read_png_chunk_info(file)
        while cur_chunk.name != b"PLTE":
            file.seek(4 + cur_chunk.length, io.SEEK_CUR)
            try:
                cur_chunk = read_png_chunk_info(file)
            except:
                return "No palette"
        file.seek(cur_chunk.length, io.SEEK_CUR)
        return file.read(4)


first_crc = get_png_palette_crc(parsed_args.first)

print("First: {}".format(parsed_args.first))
for other_file in parsed_args.others:
    print("{}: ".format(other_file), end="")
    other_crc = get_png_palette_crc(other_file)
    if not isinstance(other_crc, bytes):
        print("N/A ({})".format(other_crc))
    elif other_crc != first_crc:
        print("✗")
    else:
        print("✓")