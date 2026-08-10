@echo off
cd /d "%~dp0backend"
set PATH=%USERPROFILE%\.local\bin;%PATH%

echo.
echo  Installing dependencies (first run may take 1-2 minutes)...
pip install -q -r requirements.txt
if errorlevel 1 (
    echo Failed to install packages. Make sure Python 3.10+ is installed.
    pause
    exit /b 1
)

echo.
echo  College FAQ Chatbot is starting...
echo  Open http://localhost:8000 in your browser
echo  Press Ctrl+C to stop the server
echo.

uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
pause
