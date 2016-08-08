@echo off
tools\7za a -tzip -mm=Deflate -mx=0 -x!".git*" -x!"*.bat*" -x!"maps\*.backup*" -x!"maps\*.dbs*" ..\wolf_boa.pk3 *