@echo off
setlocal
title HIPG Finance CBSL FX Rate App
echo ============================================================
echo   HIPG Finance — Official CBSL Automated FX Rate App
echo ============================================================

set "PY_EXE=%LOCALAPPDATA%\Programs\Python\Python314\python.exe"
if not exist "%PY_EXE%" (
    where python.exe >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        set "PY_EXE=python.exe"
    ) else (
        echo [ERROR] Python 3.14 was not found at %PY_EXE%
        pause
        exit /b 1
    )
)

echo Starting backend server...
cd /d "%~dp0"
start "HIPG FX Backend Server" /min "%PY_EXE%" -m backend.server

timeout /t 2 /nobreak >nul

echo Launching Desktop Application Window...
start msedge.exe --app=http://127.0.0.1:8080

echo HIPG FX App is running at http://127.0.0.1:8080
exit /b 0
