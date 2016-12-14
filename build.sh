#!/usr/bin/env bash

if [[ -n "$(uname -s | grep -i 'MINGW\|CYGWIN\|MSYS')" ]]; then
  # We're using Bash on Windows!
  sevenzip=./tools/7za.exe
else
  sevenzip=7z
fi

separate_hires_pack=0
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
-z    --no-hires  Pack the hi-res sprite pack separately.
HELP
    exit 0
  fi

  # Release build or development build
  if [[ "$1" == "-r" || "$1" == "--release" ]]; then
    cmthd='LZMA'
    shift
    continue
  fi

  # Separate hi-res sprite pack
  if [[ "$1" == "-z" || "$1" == "--no-hires" ]]; then
    separate_hires_pack=1
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

if [[ $separate_hires_pack -eq 0 ]]; then
  $sevenzip a -tzip -mmt=on -mm=$cmthd -mx=9 -ssc -xr@'tools/7zExcludeList.txt' -x@'tools/7zExcludeListDir.txt' $zipname *
  if [[ $? -eq 0 ]]; then mv $zipname ..; fi
else
  # Hi-res sprite pack pk3 filename
  hzipprefix="${zipprefix}_hd"
  hzipname="$hzipprefix-$zipcommit-$(git log -n 1 --date=short --format=%cd | sed 's/\([[:digit:]]\{4\}\)-\([[:digit:]]\{2\}\)-\([[:digit:]]\{1,2\}\)$/\1\2\3/').pk3"

  $sevenzip a -tzip -mmt=on -mm=$cmthd -mx=9 -ssc -xr@'tools/7zExcludeList.txt' -x@'tools/7zExcludeListDir.txt' -x!hires $zipname *
  if [[ $? -eq 0 ]]; then mv $zipname ..; fi
  $sevenzip a -tzip -mmt=on -mm=$cmthd -mx=9 -ssc $hzipname hires
  if [[ $? -eq 0 ]]; then mv $hzipname ..; fi
fi
