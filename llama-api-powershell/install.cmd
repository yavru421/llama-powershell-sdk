@echo off
echo Installing Llama PowerShell SDK...
echo.
echo This batch file will help bypass PowerShell execution policy restrictions.
echo.
powershell.exe -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
echo Installation complete. Press any key to exit.
pause >nul
