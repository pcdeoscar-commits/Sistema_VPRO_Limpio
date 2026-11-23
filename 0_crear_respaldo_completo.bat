@echo off
chcp 65001 > nul
title VPRO ERP - Generar Respaldo Completo Maestro

echo =====================================================================
echo 📦 VPRO WORKSPACE ERP - GENERADOR DE RESPALDO INTEGRAL MAESTRO
echo =====================================================================
echo.

python generar_respaldo_completo.py

echo.
pause
