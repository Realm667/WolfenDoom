#!/usr/bin/env zsh
zmodload zsh/pcre

fontdir=${1:?Please specify a font directory}

process_char(){
    fontchar=$1
    yoffset=${2:=0}
    pcre_compile -im '\s(\d+)x(\d+)\s'
    charinfo="$(identify $fontchar 2>/dev/null)" || continue
    pcre_match -a chardims $charinfo
    charwidth=${chardims[1]}
    charheight=${chardims[2]}
    channels=3
    hexdigitsperoctet=2
    pixelstride=$((channels * hexdigitsperoctet))
    charrowstride=$((charwidth * pixelstride))
    charcolstride=$((charheight * pixelstride))
    rowbreak="s/([[:alnum:]]{${charrowstride}})/\1\n/g"
    colbreak="s/([[:alnum:]]{${charcolstride}})/\1\n/g"
    : ${(Af)charrow::="$(convert $fontchar -depth 8 rgb:- | \
        xxd -p -g 0 | tr -d '\n' | sed -E $rowbreak)"}
    : ${(Af)charcol::="$(convert $fontchar -depth 8 -rotate 90 rgb:- | \
        xxd -p -g 0 | tr -d '\n' | sed -E $colbreak)"}
    blankrow=""
    repeat $charrowstride blankrow+="0"
    blankcol=""
    repeat $charcolstride blankcol+="0"
    cutleftcols=0
    lastleftcol=0
    cutrightcols=0
    lastrightcol=0
    cuttoprows=0
    cutbtmrows=0
    lasttoprow=0
    lastbtmrow=0
    # Find first and last non-blank rows
    for ((rownum=1; rownum <= ${#charrow}; rownum++)) {
        rowdata=${charrow[$rownum]}
        if [[ "$rowdata" == "$blankrow" ]]; then
            cuttoprows=$rownum
        else
            lasttoprow=$rownum
            break
        fi
    }
    for ((rownum=${#charrow}; rownum > 0; rownum--)) {
        rowdata=${charrow[$rownum]}
        if [[ "$rowdata" == "$blankrow" ]]; then
            ((cutbtmrows += 1))
        else
            lastbtmrow=$rownum
            break
        fi
    }
    # Find first and last non-blank columns
    for ((colnum=1; colnum <= ${#charcol}; colnum++)) {
        coldata=${charcol[$colnum]}
        if [[ "$coldata" == "$blankcol" ]]; then
            cutleftcols=$colnum
        else
            lastleftcol=$colnum
            break
        fi
    }
    for ((colnum=${#charcol}; colnum > 0; colnum--)) {
        coldata=${charcol[$colnum]}
        if [[ "$coldata" == "$blankcol" ]]; then
            ((cutrightcols += 1))
        else
            lastrightcol=$colnum
            break
        fi
    }
    : ${(As: :)origoffsets::="$(python3 grab_get.py $fontchar)"}
    offsety=$(( origoffsets[2] - yoffset - (lasttoprow - 1) ))
    convert $fontchar -chop ${cutrightcols}x${cutbtmrows}+${lastrightcol}+${lastbtmrow} -chop ${cutleftcols}x${cuttoprows} $fontchar
    pngcrush -ow -rem alla $fontchar
    python3 grab_inject.py $fontchar 0 $offsety
}

for fontchar in ${fontdir}/*(.); do
    process_char $fontchar $2
done
