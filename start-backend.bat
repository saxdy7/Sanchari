@echo off
echo Starting Sanchari Backend Server...
cd /d "%~dp0backend"
call npm run start:dev
