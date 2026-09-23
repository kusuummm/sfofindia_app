@echo off
title Pinggy Live Tunnel (Port 8099)
echo ===================================================
echo Starting Pinggy Public Tunnel for Port 8099...
echo ===================================================
echo Keep this window OPEN while testing.
echo Copy the HTTPS URL displayed below (e.g. https://xxxx.run.pinggy-free.link)
echo and paste it into the Flutter app's Server Settings.
echo ===================================================
echo.
ssh -p 443 -R0:127.0.0.1:8099 -o StrictHostKeyChecking=no a.pinggy.io
pause
