@echo off
echo Llama PowerShell SDK Automated Installer
echo ----------------------------------------
echo.

REM Bypass PowerShell execution policy and run install.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"

echo.
echo If you want to import the modules manually, run:
echo   Import-Module "%CD%\src\llama_api_powershell\LlamaApi.psd1"
echo   Import-Module "%CD%\src\LlamaAgent\LlamaAgent.psm1"
echo.
echo For troubleshooting, see README.md.
echo.
pause
