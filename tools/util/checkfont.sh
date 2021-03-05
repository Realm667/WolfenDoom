#!/usr/bin/env zsh
# Check whether certain font characters are missing or not
zmodload zsh/zutil

zparseopts -D -E -A params -source:

fontname=${1:?Font required}
source=${params[--source]}
: ${source:="$(csvcut -c1 fontchars.csv)"}

: ${(Af)charz::="${source}"}
: ${(Af)flist::="$(ls -1 $fontname)"}

setopt extendedglob
grep -i cellsize (#i)$fontname/font.inf | read cellsize

fonttype=$?
if ((fonttype == 1)); then
    # Variable-width
    i=2
    while [[ -n ${charz[$i]} ]] {
        # Remove quote marks
        if [[ ${charz[$i]} == \"* ]]; then
            charz[$i]=${charz[$i][2,-2]}
        fi
        if [[ ${charz[$i]} == \"\"* ]]; then
            charz[$i]=${charz[$i]:1}
        fi
        charcode=${charz[$i][5,9]}
        if [[ -n ${flist[(r)${charcode}*]} ]]; then
            print '✓'
        else
            print "U -> ${charcode}.png"
        fi
        ((i++))
    }
else
    zmodload zsh/pcre
    # Monospace, requires ImageMagick
    pcre_compile '(\d+)\s*,\s*(\d+)'
    pcre_match -a celldim $cellsize
    pcre_compile '(\d+)x(\d+)'
    i=2
    curimg=""
    curimgcharsleft=0
    # Monospace font characters are stored in sheets
    typeset -A imginfos
    for image in $flist; do
        identify $fontname/$image 2>/dev/null | read imgdim
        if [[ $? -ne 0 ]]; then
            continue
        fi
        pcre_match -a imgdim $imgdim
        imginfos[$image]="$(((imgdim[1] / celldim[1]) * (imgdim[2] / celldim[2]))) $((imgdim[1] / celldim[1])) $((imgdim[2] / celldim[2]))"
    done
#     for base count in ${(kv)imginfos[@]}; do
#         print $((0x${base:0:4})) $count
#     done
    convert -size $celldim[1]x$celldim[2] -depth 8 canvas:none rgba:- | base64 -w 0 | read blankchar
    while [[ -n ${charz[$i]} ]] {
        if [[ ${charz[$i]} == \"* ]]; then
            charz[$i]=${charz[$i][2,-2]}
        fi
        if [[ ${charz[$i]} == \"\"* ]]; then
            charz[$i]=${charz[$i]:1}
        fi
        charcode=$((0x${charz[$i][5,9]}))
        found=0
        for base count cols rows in ${(kvs@ @)imginfos[@]}; do
            colw=$((cols * celldim[1]))
            rowh=$((rows * celldim[2]))
            end=$((0x${base:0:4} + count))
            if (( charcode >= 0x${base:0:4} && charcode < end )); then
                charindex=$((charcode - 0x${base:0:4}))
                charcol=$((charindex % cols))
                charrow=$((charindex / cols))
                charx=$((charcol * celldim[1]))
                chary=$((charrow * celldim[2]))
                convert $fontname/$base -crop "$celldim[1]x$celldim[2]+$charx+$chary" -channel RGB -evaluate Set 0 rgba: | base64 -w 0 | read chardata
                found=1
                if [[ $chardata != $blankchar ]]; then
                    print '✓'
                else
                    print "U -> ${base}@${charcol},${charrow} (${charx},${chary})"
                fi
                break
            fi
        done
        if ((found == 0)); then
            printf "U -> %04X.png\n" $charcode
        fi
        ((i++))
    }
fi