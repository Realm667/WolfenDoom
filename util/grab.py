# Output a grAb chunk for copy/pasting into a PNG

import struct
import zlib
import argparse
import sys

parser = argparse.ArgumentParser(description="Output a grAb chunk for PNGs")
parser.add_argument('x', type=int, help="x offset")
parser.add_argument('y', type=int, help="y offset")

offsets = parser.parse_args()

grabs = struct.pack(">ii", offsets.x, offsets.y)
crc = struct.pack(">I", zlib.crc32(grabs, 0))
size = struct.pack(">I", 8)
output = size + b"grAb" + grabs + crc

sys.stdout.buffer.write(output)