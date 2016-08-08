#!/bin/zsh

git checkout master
git pull origin master

zipprefix="wolf_boa"
zipname="$zipprefix-$(git log -n 1 --date=short --format=%h-%cd | sed 's/\([[:digit:]]\{4\}\)-\([[:digit:]]\{2\}\)-\([[:digit:]]\{1,2\}\)$/\1\2\3/').pk3"

if [[ "$1" == '-dev' ]]; then
  cmthd='Deflate'
  shift
else
  cmthd='LZMA'
fi

# print -l **/*~*.bat~*.exe~.*~*.bak~source/*(#q.on) | zip -@ $zipname
7z a -tzip -mmt=on -mm=$cmthd -mx=9 -ssc -x!'.git*' -x!'**/*.bak' -x!'*.bat' -x!'**/*.exe' -x!'**/*.acs' $zipname *

mv $zipname ..

