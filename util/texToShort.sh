#!/usr/bin/env zsh

hitexs=(hires/textures/*)
fullpaths=()
shortexs=()
modify=1
rbscript="$(cat)" <<RUBY
badtextures = ENV["BADTEXTURES"].split("|")
good = true
begin
    line = \$_.downcase
rescue
    good = false
end
found = false

if good
    badtextures.each { |texture|
        if not line.index(texture) === nil
            lastdirsep = texture.rindex("/")
            extension = texture.index(".")
            short = texture[lastdirsep,extension - lastdirsep]
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

min() {
    if (( $1 < $2 )); then
        print $1
    else
        print $2
    fi
}

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
        texstoreplace+="$tpath\\\|"
    done
    setopt extendedglob
    #progress=0
    #mapwads=((#i)maps/*.wad)
    #typeset -F mapwadcount=${#mapwads}
    for mapwad in (#i)maps/*.wad; do
        # old bad sed script
        # sed -i -e "/texture\(top\|middle\|bottom\|floor\|ceiling\)[[:space:]]*=[[:space:]]*\"${texstoreplace}\";/s/\"textures\/\(.\+\?\)\.[[:alnum:]]\+\";/\"\1\";/gI" $mapwad
        BADTEXTURES=$texstoreplace ruby -i.bak -nl -e $rbscript $mapwad
        #((progress++))
        #print "$mapwad done ($((progress / mapwadcount * 100))% overall)"
    done
    setopt noextendedglob
fi