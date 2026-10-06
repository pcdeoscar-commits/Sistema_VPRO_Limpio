@echo off
chcp 65001 > nul
title VPRO ERP - Habilitar Acceso por Intranet en Firewall
echo =====================================================================
echo 🛡️ VPRO WORKSPACE - CONFIGURACIÓN DE FIREWALL PARA INTRANET
echo =====================================================================
echo.
echo Este script abre el puerto TCP 8521 en el Firewall de Windows
echo para permitir que otros colaboradores en la red local (LAN)
echo puedan conectarse al sistema y compartir archivos sin restricciones.
echo.
echo Solicitando permisos de Firewall...
netsh advfirewall firewall delete rule name="VPRO ERP Puerto 8521" >nul 2>&1
netsh advfirewall firewall add rule name="VPRO ERP Puerto 8521" dir=in action=allow protocol=TCP localport=8521 profile=any >nul 2>&1

if %ERRORLEVEL% equ 0 (
    echo [OK] Puerto 8521 habilitado correctamente en el Firewall de Windows.
    echo      Cualquier equipo en la red local puede ingresar al sistema.
) else (
    echo [AVISO] Para registrar la regla en Windows Firewall:
    echo         Haz clic derecho sobre este archivo y elige "Ejecutar como administrador".
)
echo.
echo =====================================================================
pause
