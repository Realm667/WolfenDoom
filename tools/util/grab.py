#!/usr/bin/env python3
# Output a grAb chunk for copy/pasting into a PNG

import struct
import zlib
import argparse
import sys

# Offsets as arguments
parser = argparse.ArgumentParser(description="Output a grAb chunk that can be copied and pasted into PNG files.")
parser.add_argument('x', type=int, help="x offset")
parser.add_argument('y', type=int, help="y offset")
parser.add_argument('--bad', help="Use bad CRC calculation", action='store_true')
offsets = parser.parse_args()

# Convert to binary
if offsets.bad:
    grabs = struct.pack("!ii", offsets.x, offsets.y)
else:
    grabs = b"grAb" + struct.pack("!ii", offsets.x, offsets.y)

crc = struct.pack("!I", zlib.crc32(grabs))
size = struct.pack("!i", 8)

if offsets.bad:
    output = size + b"grAb" + grabs + crc
else:
    output = size + grabs + crc

# Write to stdout
sys.stdout.buffer.write(output)