#!/usr/bin/env python3
"Inject a grAb chunk into a PNG file"
import argparse
import png as png_util
import struct

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=
                                     "Get offsets from a PNG file")
    parser.add_argument('png', help="The PNG file to get the grAb offset "
                                    "info from")
    args = parser.parse_args()
    png = png_util.PNGFile()
    png.read(args.png)
    grab_index = png.chunk_index(b"grAb")
    if grab_index >= 0:
        x, y = struct.unpack(">2i", png.chunks[grab_index].data)
        print(x, y)
