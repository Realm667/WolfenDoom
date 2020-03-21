#!/usr/bin/env zsh

hitexs=(hires/textures/*)
fullpaths=()
shortexs=()
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
            print "\nTexture \"${lotex}\", ${hiwidth}, ${hiheight} \{\n\tXScale ${xscale}\n\tYScale ${yscale}\n\tPatch \"${texname}\", 0, 0\n\}"
            hitexs[i]=()
            ((i--))
        else
            fullpaths+=(textures/${shortexname}*([1]))
            shortexs+=($shortexname)
        fi
    fi
done

# print -l $hitexs
# print -l $fullpaths
# print -l $shortexs
if ((modify == 1)); then
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
        maptext="$(python3 util/get_textmap.py $mapwad)"
        BADTEXTURES=$texstoreplace ruby -n -e $rbscript $maptext | python3 util/put_textmap.py $mapwad
        rm $maptext
        #((progress++))
        #print "$mapwad done ($((progress / mapwadcount * 100))% overall)"
    done
    setopt noextendedglob
fi