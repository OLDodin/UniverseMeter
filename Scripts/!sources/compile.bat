@setlocal enableextensions enabledelayedexpansion
@echo off
echo Starting...
for %%i in (*.lua) do (
set nam=%%i
echo Converting %%i
luajit-2.0.4.exe -b "%%i" "../!nam:~0,-4!.luac" 
)
echo Done
pause