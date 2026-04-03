@echo off
echo ===== Smart Crop Advisory Diagnostics =====
python --version
node --version
npm --version
echo Checking ports...
netstat -ano | findstr ":8000"
netstat -ano | findstr ":5173"
echo Done.
