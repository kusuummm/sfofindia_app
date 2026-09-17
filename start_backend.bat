@echo off
title Shaheed Foundation Backend Server (Port 8099)
echo ===================================================
echo Starting Shaheed Foundation API Server on Port 8099...
echo ===================================================
cd /d "C:\Users\hp\OneDrive\Desktop\php\sfofindia_fixed"
c:\php\php.exe -S 0.0.0.0:8099 router.php
pause
