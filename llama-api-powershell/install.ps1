# install.ps1
# Installer for llama-api-powershell (local dev or global)

$modulePath = Join-Path $PSScriptRoot 'src/llama_api_powershell/LlamaApi.psd1'
$agentModulePath = Join-Path $PSScriptRoot 'src/LlamaAgent/LlamaAgent.psm1'
if (Test-Path $modulePath) {
    Import-Module $modulePath -Force
    Write-Output "llama-api-powershell module imported from $modulePath (local session only)"
    if (Test-Path $agentModulePath) {
        Import-Module $agentModulePath -Force
        Write-Output "LlamaAgent module imported from $agentModulePath (local session only)"
    } else {
        Write-Output "Agent module not found at $agentModulePath. Agent features will not be available."
    }
    $globalInstall = Read-Host 'Do you want to install globally for all sessions? (y/n)'
    if ($globalInstall -eq 'y') {
        $targetDir = Join-Path $env:USERPROFILE 'Documents\PowerShell\Modules\LlamaApi'
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir | Out-Null
        }
        Copy-Item -Path (Join-Path $PSScriptRoot 'src\llama_api_powershell\*') -Destination $targetDir -Recurse -Force
        $agentTargetDir = Join-Path $targetDir 'LlamaAgent'
        if (-not (Test-Path $agentTargetDir)) {
            New-Item -ItemType Directory -Path $agentTargetDir | Out-Null
        }
        Copy-Item -Path (Join-Path $PSScriptRoot 'src\LlamaAgent\*') -Destination $agentTargetDir -Recurse -Force
        Write-Output "LlamaAgent module copied to $agentTargetDir. You can now use Import-Module LlamaAgent in any session."
        Write-Output "LlamaApi module copied to $targetDir. You can now use Import-Module LlamaApi in any session."
    }
} else {
    Write-Output "Module not found at $modulePath. Please check your repo structure."
}

# Run all tests after install
$testDir = Join-Path $PSScriptRoot 'tests'
if (Test-Path $testDir) {
    Write-Output "Running all tests in $testDir..."
    Get-ChildItem -Path $testDir -Filter *.ps1 | ForEach-Object {
        Write-Output "Running test: $($_.Name)"
        try {
            & $_.FullName
        } catch {
            Write-Output "Test $($_.Name) failed: $($_.Exception.Message)"
        }
    }
    Write-Output "All tests completed."
} else {
    Write-Output "No tests directory found."
}
