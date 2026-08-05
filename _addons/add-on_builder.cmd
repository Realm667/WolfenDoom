@echo off

rmdir /s /q release 2>nul

pushd source
for /F %%I in ('dir /ad /b') do (
  pushd "%%I"
  "..\..\7za.exe" a -tzip -mx1 "..\..\release\addons\%%I.pk3" -x!addoninfo.txt -x!gameinfo.txt -x!preview *
  "..\..\7za.exe" a -tzip -mx1 "..\..\release\addons\addon_%%I.boa" addoninfo.txt gameinfo.txt preview
  popd
)
popd

copy /y "z_boa_addon_README.txt" "release\addons\z_boa_addon_README.txt" >nul
