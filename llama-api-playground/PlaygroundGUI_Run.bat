@echo off
REM Launch the Llama API Playground GUI with all dependencies

REM Set working directory to script location
cd /d "%~dp0src"

REM Run with PowerShell 7+ if available, fallback to Windows PowerShell
where pwsh >nul 2>nul
if %errorlevel%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File PlaygroundGUI.ps1
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File PlaygroundGUI.ps1
)
