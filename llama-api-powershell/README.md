# llama-api-powershell

A PowerShell SDK for interacting with the Llama API and agent tools.

## Installation

### Option 1: Download Release Package
1. Download `llama-powershell-sdk-v1.0.0.zip` from the [Releases page](https://github.com/yavru421/llama-powershell-sdk/releases)
2. Extract the ZIP file to your desired location
3. Open PowerShell and navigate to the extracted folder
4. Run the installer:
   ```powershell
   .\install.ps1
   ```
5. Choose 'y' when prompted for global installation (recommended)

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

- **Missing API Key**: Ensure you have set the `LLAMA_API_KEY` environment variable or passed `-ApiKey` to `New-LlamaClient`.
- **Module Import Errors**: Double-check the import path and that you are using PowerShell 5.1 or later.
- **Network Issues**: Verify your internet connection and that the Llama API endpoint is reachable.
- **Cmdlet Not Found**: Make sure the module is imported in your session.

## Author

Created by John Daniel Dondlinger, 2025.
