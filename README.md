![image(21)](https://github.com/user-attachments/assets/7572d5a5-b8d4-4150-87b5-677e3bbea3ce)

# llama-api-powershell

A PowerShell SDK for interacting with the Llama API and agent tools.

---

[![Sponsor Me](https://img.shields.io/badge/Sponsor%20Me-GitHub%20Sponsors-blue)](https://github.com/sponsors/yavru421)

---

## Installation

### Option 1: Download Release Package
1. Download `llama-powershell-sdk-v1.0.1.zip` from the [Releases page](https://github.com/yavru421/llama-powershell-sdk/releases)
2. Extract the ZIP file to your desired location
3. Navigate to the extracted folder

**Recommended: Automated Installer**
```cmd
install-all.bat
```
This will automatically bypass PowerShell execution policy, run the installer, and prompt for global installation.

**Alternative Methods:**

- `install.cmd` (bypasses execution policy)
- `powershell.exe -ExecutionPolicy Bypass -File .\install.ps1`
- `./install.ps1` (may require execution policy changes)

4. Choose 'y' when prompted for global installation (recommended)

### Option 2: Clone Repository
From the repo root, run:

```powershell
./install.ps1
```

### Option 3: Manual Import
Import the modules directly without installation:

```powershell
Import-Module ./src/llama_api_powershell/LlamaApi.psd1
Import-Module ./src/LlamaAgent/LlamaAgent.psm1
```

## Features

- Core Llama API client and cmdlets
- Agent module for tool calling (e.g., es.exe, Everything.exe)
- Example scripts and tests

## Usage

### API Client
```powershell
$env:LLAMA_API_KEY = 'your-api-key-here'
$client = New-LlamaClient
$result = Invoke-LlamaApiRequest -Client $client -Method GET -Path '/models'
```

### Agent Usage
```powershell
Import-Module LlamaAgent
Start-LlamaAgent
```

To call a tool via the agent:
```
#file:es.exe -help
```

### Global Import
After global install, use:
```powershell
Import-Module LlamaApi
Import-Module LlamaAgent
```

## Folder Structure
- `src/llama_api_powershell/` - Core module
- `src/LlamaAgent/` - Agent module
- `examples/` - Example scripts
- `tests/` - Tests

## Troubleshooting
- Ensure API key is set
- Use correct import paths
- Agent features require LlamaAgent module

## Author
Created by John Daniel Dondlinger, 2025.

```powershell
$client = New-LlamaClient -ApiKey 'sk-...' -BaseUrl 'https://api.llama.com/v1/'
$result = Invoke-LlamaApiRequestExtras -Client $client -Method GET -Path '/models' -ExtraHeaders @{ 'X-Test' = '1' } -ExtraQuery @{ foo = 'bar' } -ExtraBody @{ extra = 123 }
```

### Invoke-LlamaTool
Call function-calling models with tools/functions:

```powershell
$client = New-LlamaClient -ApiKey 'sk-...' -BaseUrl 'https://api.llama.com/v1/'
$tools = @(@{ type = 'function'; function = @{ name = 'test'; description = 'desc'; parameters = @{} } })
$result = Invoke-LlamaTool -Client $client -Model 'llama-2-7b-chat' -Messages @(@{role='user';content='hi'}) -Tools $tools
```

### Invoke-LlamaFineTuning
Manage fine-tuning jobs:

```powershell
# Start a job
$params = @{ dataset = 'file-xxx'; model = 'llama-2-7b' }
$result = Invoke-LlamaFineTuning -Client $client -Action start -Parameters $params

# Check status
$result = Invoke-LlamaFineTuning -Client $client -Action status -Parameters @{ job_id = 'job-xxx' }

# Cancel job
$result = Invoke-LlamaFineTuning -Client $client -Action cancel -Parameters @{ job_id = 'job-xxx' }
```

## Troubleshooting

### PowerShell Execution Policy Issues
If you see an error like "cannot be loaded. The file is not digitally signed", try these solutions:

**Solution 1: Use the batch file installer (Recommended)**
```cmd
install.cmd
```

**Solution 2: Temporarily bypass execution policy**
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\install.ps1
```

**Solution 3: Change execution policy for current user**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

**Solution 4: Run specific commands manually**
```powershell
# Set execution policy and run
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\install.ps1
```

### Other Common Issues
- **Missing API Key**: Ensure you have set the `LLAMA_API_KEY` environment variable or passed `-ApiKey` to `New-LlamaClient`.
- **Module Import Errors**: Double-check the import path and that you are using PowerShell 5.1 or later.
- **Network Issues**: Verify your internet connection and that the Llama API endpoint is reachable.
- **Cmdlet Not Found**: Make sure the module is imported in your session.

### Manual Installation (Alternative)
If automation fails, manually copy the modules:
1. Copy `src/llama_api_powershell/` to `$env:USERPROFILE\Documents\PowerShell\Modules\LlamaApi\`
2. Copy `src/LlamaAgent/` to `$env:USERPROFILE\Documents\PowerShell\Modules\LlamaAgent\`
3. Import: `Import-Module LlamaApi; Import-Module LlamaAgent`

## Author

Created by John Daniel Dondlinger, 2025.