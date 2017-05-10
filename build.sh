#!/usr/bin/env bash

if [[ -n "$(uname -s | grep -i 'MINGW\|CYGWIN\|MSYS')" ]]; then
  # We're using Bash on Windows!
  sevenzip=./tools/7za.exe
else
  sevenzip=7z
fi

cmthd='Deflate'

# Parse arguments
while [[ $# > 0 ]]; do

  # Help
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<HELP
WolfenDoom sh.ake 'n baker - Linux/MacOS build script for
              WolfenDoom: Blade of Agony

-h    --help      Show this help
-r    --release   Use LZMA compression instead of Deflate compression
                  Results in smaller pk3, but takes longer, and cannot be
                  read or modified using SLADE.
HELP
    exit 0
  fi

  # Release build or development build
  if [[ "$1" == "-r" || "$1" == "--release" ]]; then
    cmthd='LZMA'
    shift
    continue
  fi

  # Unrecognized argument
  shift
done

git checkout master
git pull origin master

# Regular pk3 filename
zipprefix="wolf_boa"
zipcommit="$(git log -n 1 --format=%h)"
zipname="$zipprefix-$zipcommit-$(git log -n 1 --date=short --format=%cd | sed 's/\([[:digit:]]\{4\}\)-\([[:digit:]]\{2\}\)-\([[:digit:]]\{1,2\}\)$/\1\2\3/').pk3"

$sevenzip a -tzip -mmt=on -mm=$cmthd -mx=9 -ssc -xr@'tools/7zExcludeList.txt' -x@'tools/7zExcludeListDir.txt' $zipname *
if [[ $? -eq 0 ]]; then mv $zipname ..; fi
