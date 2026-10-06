@echo off
chcp 65001 > nul
title VPRO ERP - Instalar Extensiones de VS Code
echo =====================================================================
echo 🛠️ VPRO WORKSPACE - INSTALADOR DE EXTENSIONES DE VISUAL STUDIO CODE
echo =====================================================================
echo.
echo Este script instala todas las extensiones que tienes configuradas en la PC principal:
echo • Python, Pylance, Debugpy
echo • GitHub Pull Requests y herramientas de Git
echo • Google Antigravity
echo • SQLTools y Base de Datos
echo • Docker y Edge DevTools
echo • Matplotlib Pilot, Preview de imágenes y Prettier
echo.

where code >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] No se encontró el comando 'code' de Visual Studio Code en el PATH.
    echo Asegúrate de abrir VS Code y activar "Shell Command: Install 'code' command in PATH"
    echo o reiniciar la consola después de instalar VS Code.
    echo.
    pause
    exit /b 1
)

set EXTENSIONES=^
ms-python.python ^
ms-python.vscode-pylance ^
ms-python.debugpy ^
ms-python.vscode-python-envs ^
github.vscode-pull-request-github ^
google.google-antigravity ^
mtxr.sqltools ^
ms-azuretools.vscode-containers ^
ms-edgedevtools.vscode-edge-devtools ^
litchi.matplotlib-pilot ^
076923.python-image-preview ^
kevinrose.vsc-python-indent ^
davidanson.vscode-markdownlint ^
esbenp.prettier-vscode ^
tomoki1207.pdf ^
ms-mssql.mssql

for %%e in (%EXTENSIONES%) do (
    echo [Instalando] %%e ...
    code --install-extension %%e --force
)

echo.
echo =====================================================================
echo 🎉 ¡TODAS LAS EXTENSIONES DE VS CODE HAN SIDO INSTALADAS!
echo Abre la carpeta del proyecto en VS Code para continuar trabajando.
echo =====================================================================
echo.
pause

