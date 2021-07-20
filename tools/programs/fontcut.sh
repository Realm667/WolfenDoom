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
    channels=3
    hexdigitsperoctet=2
    charrowstride=$((charwidth * channels * hexdigitsperoctet))
    sedscript="s/([[:alnum:]]{${charrowstride}})/\1\n/g"
    : ${(Af)chardata::="$(convert $fontchar -depth 8 rgb:- | \
        xxd -p -g 0 | tr -d '\n' | sed -E $sedscript)"}
    blankrow=""
    repeat $charrowstride blankrow+="0"
    cuttoprows=0
    cutbtmrows=0
    lasttoprow=0
    lastbtmrow=0
    for ((rownum=1; rownum <= ${#chardata}; rownum++)) {
        rowdata=${chardata[$rownum]}
        if [[ "$rowdata" == "$blankrow" ]]; then
            ((cuttoprows += 1))
        else
            lasttoprow=$rownum
            break
        fi
    }
    for ((rownum=${#chardata}; rownum > 0; rownum--)) {
        rowdata=${chardata[$rownum]}
        if [[ "$rowdata" == "$blankrow" ]]; then
            ((cutbtmrows += 1))
        else
            lastbtmrow=$rownum
            break
        fi
    }
    charheight=$((lastbtmrow - lasttoprow))
    offsety=$(( -yoffset - (lasttoprow - 1) ))
    convert $fontchar -chop 0x${cutbtmrows}+0+$((lastbtmrow)) -chop 0x${cuttoprows} $fontchar
    pngcrush -ow -rem alla $fontchar
    python3 grab_inject.py $fontchar 0 $offsety
}

for fontchar in ${fontdir}/*(.); do
    process_char $fontchar $2
done
