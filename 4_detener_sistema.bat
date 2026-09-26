@echo off
chcp 65001 > nul
title VPRO ERP - Detener Sistema

echo =====================================================================
echo 🎬 VPRO WORKSPACE ERP - DETENIENDO SERVICIOS
echo =====================================================================
echo.

echo Cerrando procesos en el puerto 8521 (Servidor Unificado VPRO)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8521" ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>nul
)

echo Cerrando procesos en el puerto 8000 (Backend legacy)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8000" ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>nul
)

echo Cerrando procesos en el puerto 5500 (Frontend legacy)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":5500" ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>nul
)

echo.
echo ✔ Todos los servicios locales de VPRO han sido detenidos.
echo.
pause
