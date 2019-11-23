@echo off
setlocal
if not exist "%~dp0\build" mkdir "%~dp0\build"
cd /d "%~dp0\build""
cmake -A x64 ..
cmake --build . --config Release -- -maxcpucount -verbosity:minimal 
if exist Release\launch-boa.exe copy Release\launch-boa.exe .. /y