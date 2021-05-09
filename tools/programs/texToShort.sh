#!/usr/bin/env zsh

hitexs=(hires/textures/*)
fullpaths=()
modify=1
rbscript="$(cat)" <<RUBY
\$\ = "\x0A"
badtextures = ENV["BADTEXTURES"].split("|").map! { |texname|
    texname.downcase
}
good = true
begin
    line = \$_.downcase
rescue
    good = false
end
found = false

texturetype = /texture(?:floor|ceiling|top|bottom|middle)\s*=/

if good and line.match? texturetype
    badtextures.each { |texture|
        if line.index(texture) != nil
            lastdirsep = texture.rindex("/") + 1
            extension = texture.index(".") - 1
            short = texture[lastdirsep..extension]
            line[texture] = short.upcase
            found = true
        end
    }
end

if found and good
    puts line
else
    puts \$_
end
RUBY

wad_py_pre="$(cat)" <<PYTHON
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
    lump_name = str(bytes(dir_entry[2:]).rstrip(b"\\\\x00"), encoding="ascii")
    dir_pos = wadfile.tell()
    wadfile.seek(lump_pos)
    lump_data = wadfile.read(lump_size)
    lumps.append(WADLump(lump_name, lump_data))
    wadfile.seek(dir_pos)

# Custom code start
PYTHON

wad_py_get="$(cat)" <<PYTHON
for lump in lumps:
    if lump.name == "TEXTMAP":
        textname = "TEXTMAP.txt"
        textfile = open(textname, "wb")
        textfile.write(lump.data)
        textfile.close()
        print(textname)
        break
PYTHON

wad_py_put="$(cat)" <<PYTHON
wadfile.seek(0)
wadfile.truncate(0)
wadfile.write(wad_id)
dir_pos = 12
offsets = []
for lump in lumps:
    if lump.name == "TEXTMAP" and has_stdin:
        lump.data = sys.stdin.buffer.read()
    offsets.append(dir_pos)
    dir_pos += len(lump.data)
wadfile.write(struct.pack(wad_head, lump_count, dir_pos))
for lump in lumps:
    wadfile.write(lump.data)
for index, lump in enumerate(lumps):
    paddedname = list(lump.name.encode("ascii"))
    while len(paddedname) < 8:
        paddedname.append(0)
    wadfile.write(struct.pack(wad_dir_entry, offsets[index], len(lump.data), *paddedname))
PYTHON

wad_py_post="$(cat)" <<PYTHON
# Custom code end
wadfile.close()
PYTHON

# Get texture names and texture definitions for textures whose names are too long
for ((i=1; i <= ${#hitexs}; i++)) do
    if grep -i ${hitexs[i]} TEXTURES.txt >/dev/null; then
        # It's in TEXTURES, remove it from list of textures
        hitexs[i]=()
        ((i--))
    else
        texname=${hitexs[i]}
        lotex=${hitexs[i]:6}
        shortnamelen=$((${hitexs[i][(I).]} - ${hitexs[i][(I)/]} - 1))
        # realtexname=${hitexs[i]:${hitexs[i][(I)/]}:$(( ${hitexs[i][(I).]} - ${hitexs[i][(I)/]} - 1 ))}
        shortexname=${hitexs[i]:${hitexs[i][(I)/]}:$shortnamelen}
        # print $shortexname
        if ((shortnamelen > 8)); then
            hisize="$(identify ${hitexs[i]} | grep -o '\b[[:digit:]]\+x[[:digit:]]\+\b' | head -n 1)"
            losize="$(identify textures/${shortexname}*([1]) | grep -o '\b[[:digit:]]\+x[[:digit:]]\+\b' | head -n 1)"
            # High res texture size
            hiwidth=${hisize:0:$((${hisize[(i)x]} - 1))}
            hiheight=${hisize:${hisize[(i)x]}}
            # Low res texture size
            typeset -F lowidth=${losize:0:$((${losize[(i)x]} - 1))}
            typeset -F loheight=${losize:${losize[(i)x]}}
            xscale=$((hiwidth / lowidth))
            yscale=$((hiheight / loheight))
            print "\nTexture \"${lotex}\", ${hiwidth}, ${hiheight} \{\n\tXScale ${xscale}\n\tYScale ${yscale}\n\tWorldPanning\n\tPatch \"${texname}\", 0, 0\n\}"
            hitexs[i]=()
            ((i--))
        else
            fullpaths+=(textures/${shortexname}*)
        fi
    fi
done

if ((modify == 1)); then
    # Set up Python scripts
    print -l ${wad_py_pre} ${wad_py_get} ${wad_py_post} > /tmp/get_textmap.py
    print -l ${wad_py_pre} ${wad_py_put} ${wad_py_post} > /tmp/put_textmap.py
    # Set up bad texture list for Ruby script
    texstoreplace=""
    for tpath in $fullpaths; do
        texstoreplace+="|$tpath"
    done
    texstoreplace="${texstoreplace:1}"
    setopt extendedglob
    #progress=0
    #mapwads=((#i)maps/*.wad)
    #typeset -F mapwadcount=${#mapwads}
    for mapwad in (#i)maps/*.wad; do
        maptext="$(python3 -I /tmp/get_textmap.py $mapwad)"
        BADTEXTURES=$texstoreplace ruby -n -e $rbscript $maptext | python3 -I /tmp/put_textmap.py $mapwad
        rm $maptext
        #((progress++))
        #print "$mapwad done ($((progress / mapwadcount * 100))% overall)"
    done
    setopt noextendedglob
fi