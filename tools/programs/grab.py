#!/usr/bin/env python3
"""
grab.py - A module for working with grAb chunks in ZDoom PNGs

Functions:
get_grabs - given an X and Y offset, get the grAb chunk bytes
"""
# Output a grAb chunk for copy/pasting into a PNG

import struct
import zlib
import argparse
import sys


def get_bytes(x=0, y=0):
    """
    Get the PNG grAb chunk bytes using the given x/y offsets
    x - The X (horizontal) offset
    y - The Y (vertical) offset
    """
    if x == 0 and y == 0:
        return None
    return struct.pack("!ii", x, y)


def get_grabs(x=0, y=0, bad=False):
    """
    Get the PNG grAb chunk data using the given x/y offsets
    x - The X (horizontal) offset
    y - The Y (vertical) offset
    bad - Whether or not to calculate the chunk's CRC incorrectly
    """
    grabytes = get_bytes(x, y)
    if grabytes is None:
        return None
    # Convert to binary
    if bad:
        grabs = grabytes
    else:
        grabs = b"grAb" + grabytes

    crc = struct.pack("!I", zlib.crc32(grabs))
    size = struct.pack("!i", 8)

    if bad:
        return size + b"grAb" + grabs + crc
    return size + grabs + crc


if __name__ == "__main__":
    # Offsets as arguments
    parser = argparse.ArgumentParser(
        description="Output a grAb chunk that can be copied and pasted into "
                    "PNG files.")
    parser.add_argument('x', type=int, help="x offset")
    parser.add_argument('y', type=int, help="y offset")
    parser.add_argument('--bad', help="Use bad CRC calculation",
                        action='store_true')
    offsets = parser.parse_args()
    output = get_grabs(**vars(offsets))

    if output is not None:
        # Write to stdout
        sys.stdout.buffer.write(output)