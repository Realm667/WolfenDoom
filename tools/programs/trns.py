#!/usr/bin/env python3
# Output a tRNS chunk for copy/pasting into a PNG

import struct
import zlib
import argparse
import sys

# Offsets as arguments
parser = argparse.ArgumentParser(description="Output a tRNS chunk that can be copied and pasted into PNG files.")
parser.add_argument('-i', '--index', type=int, default=0, help="Transparent colour index")
parsed = parser.parse_args()

# Convert to binary
data = struct.pack("!B", parsed.index)
chunk = b"tRNS" + data

crc = struct.pack("!I", zlib.crc32(chunk))
size = struct.pack("!i", len(data))

output = size + chunk + crc

# Write to stdout
sys.stdout.buffer.write(output)