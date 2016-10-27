#!/usr/bin/env zsh

git checkout master
git pull origin master

zipprefix="wolf_boa"
zipcommit="$(git log -n 1 --format=%h)"
zipname="$zipprefix-$zipcommit-$(git log -n 1 --date=short --format=%cd | sed 's/\([[:digit:]]\{4\}\)-\([[:digit:]]\{2\}\)-\([[:digit:]]\{1,2\}\)$/\1\2\3/').pk3"

if [[ "$1" == "-r" || "$1" == "--release" ]]; then
  cmthd='LZMA'
  shift
else
  cmthd='Deflate'
fi

# print -l **/*~*.bat~*.exe~.*~*.bak~source/*(#q.on) | zip -@ $zipname
noglob 7z a -tzip -mmt=on -mm=$cmthd -mx=9 -ssc -xr@'tools/7zExcludeList.txt' -x@'tools/7zExcludeListDir.txt' $zipname *

mv $zipname ..

