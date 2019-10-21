@echo off
setlocal EnableDelayedExpansion

cd %~dp0\..

for /F %%I in ('dir /a /s /b textures\') do call :process "%%~I"
goto :eof

:process
if not exist "materials\displacement\%~n1.*" goto :eof

set texfullname=%~dpnx1
set texfullname=!texfullname:*%cd%\=!
set texfullname=%texfullname:\=/%

set texbasename=%~n1%
set texbasename=%texbasename:~,8%

for %%J in ("materials\displacement\%~n1.*") do set texmaterial=%%J

call :output "%texfullname%" "%texmaterial%"
call :output "%texbasename%" "%texmaterial%"
goto :eof

:output
echo material texture %1
echo {
echo 	shader "shaders/displacement.fp"
echo 	texture displacement %2
echo }
echo.

