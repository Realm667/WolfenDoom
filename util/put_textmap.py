#!/usr/bin/env python3
# Replace textmap in a Doom WAD
import sys
import struct

class WADLump:
    def __init__(self, name = "", data = b""):
        self.data = data
        self.name = name

wad_head = "<2I"
wad_dir_entry = "<2I8B"
wad_id = b"PWAD"
wadname = sys.argv[1]
has_stdin = sys.stdin.isatty() is False

# Get position of directory
wadfile = open(wadname, "r+b")
if wadfile.read(4) != wad_id:
    print("Not a valid WAD file!")
    exit(1)
lump_count, dir_pos = struct.unpack(wad_head, wadfile.read(8))

# Read all lumps in WAD
wadfile.seek(dir_pos)
lumps = []
for dire in range(lump_count):
    dir_entry = struct.unpack(wad_dir_entry, wadfile.read(16))
    lump_pos = dir_entry[0]
    lump_size = dir_entry[1]
    lump_name = str(bytes(dir_entry[2:]).rstrip(b"\x00"), encoding="ascii")
    dir_pos = wadfile.tell()
    wadfile.seek(lump_pos)
    lump_data = wadfile.read(lump_size)
    lumps.append(WADLump(lump_name, lump_data))
    wadfile.seek(dir_pos)

# Custom code start
wadfile.write(wad_id)
dir_pos = 12
offsets = []
for lump in lumps:
    if lump.name == "TEXTMAP" and has_stdin:
        lump.data = sys.stdin.buffer.read()
    dir_pos += len(lump.data)
    offsets.append(dir_pos)
wadfile.write(struct.pack(wad_head, lump_count, dir_pos))
for lump in lumps:
    wadfile.write(lump.data)
for index, lump in enumerate(lumps):
    paddedname = bytearray(lump.name.encode("ascii"))
    while len(paddedname) < 8:
        paddedname.append(0)
    wadfile.write(struct.pack(wad_dir_entry, offsets[index], len(lump.data), paddedname))
# Custom code end
wadfile.close()