@echo off
echo Stopping servers...
taskkill /f /im python.exe 2>nul
taskkill /f /im node.exe 2>nul
echo Done.
