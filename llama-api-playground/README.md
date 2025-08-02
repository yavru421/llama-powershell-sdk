# Llama API Playground for PowerShell

A modern, interactive playground for experimenting with Llama models, completions, moderation, and more—using a PowerShell GUI (GridView-based) interface.

## Features
- Explore and test Llama API endpoints
- Send chat/completion/moderation requests
- View and compare responses in a grid UI
- Save and load request/response history
- Designed for sysadmins, developers, and AI enthusiasts

## Getting Started
- Requires Windows PowerShell 5.1+ or PowerShell 7+
- Uses built-in `Out-GridView` for GUI
- See `src/Playground.ps1` for main entry point

## Directory Structure
- `src/` — Main scripts and modules
- `tests/` — Playground tests

## Usage
```powershell
cd .\llama-api-playground\src
./Playground.ps1
```
