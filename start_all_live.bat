@echo off
title Start Backend and Pinggy Live Tunnel
echo ===================================================
echo Launching PHP Backend and Pinggy Public Tunnel...
echo ===================================================

echo Starting PHP Backend Server (Port 8099)...
start "Backend Server" "%~dp0start_backend.bat"

timeout /t 2 /nobreak >nul

echo Starting Pinggy Tunnel...
start "Pinggy Tunnel" "%~dp0start_pinggy.bat"

echo.
echo Both services launched! Keep their windows open while testing.
