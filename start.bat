@echo off
echo Starting Smart Crop Advisory System...
start "Backend" cmd /k "cd backend && python app.py"
timeout /t 3
start "Frontend" cmd /k "cd frontend && npm install && npm run dev"
timeout /t 5
start http://localhost:5173
