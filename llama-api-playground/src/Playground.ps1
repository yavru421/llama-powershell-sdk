# Llama API Playground for PowerShell
# Main entry point


# Robust module import logic
$modulePaths = @(
    "$PSScriptRoot\..\..\llama-api-powershell\src\llama_api_powershell\LlamaApi.psm1",
    "$PSScriptRoot\..\..\src\llama_api_powershell\LlamaApi.psm1"
)
$imported = $false
foreach ($path in $modulePaths) {
    if (Test-Path $path) {
        Import-Module $path -Force
        $imported = $true
        break
    }
}
if (-not $imported) {
    Write-Error "Could not find LlamaApi.psm1. Please check the SDK path."
    exit 1
}
. "$PSScriptRoot\Utils.ps1"

function Show-LlamaApiPlayground {
    [CmdletBinding()]
    param()

    $menu = @(
        [PSCustomObject]@{ Action = 'Chat Completion'; Description = 'Send a chat/completion request to Llama API' }
        [PSCustomObject]@{ Action = 'Moderation'; Description = 'Send a moderation request to Llama API' }
        [PSCustomObject]@{ Action = 'List Models'; Description = 'List available Llama models' }
        [PSCustomObject]@{ Action = 'Advanced Features'; Description = 'Multi-turn chat, batch processing, and more' }
        [PSCustomObject]@{ Action = 'View History'; Description = 'View request/response history' }
        [PSCustomObject]@{ Action = 'Exit'; Description = 'Exit the playground' }
    )

    while ($true) {
        $choice = $menu | Out-GridView -Title 'Llama API Playground - Main Menu' -PassThru
        if (-not $choice) { break }
        switch ($choice.Action) {
            'Chat Completion' { & "$PSScriptRoot\ChatCompletionUI.ps1" }
            'Moderation'      { & "$PSScriptRoot\ModerationUI.ps1" }
            'List Models'     { & "$PSScriptRoot\ListModelsUI.ps1" }
            'Advanced Features' { & "$PSScriptRoot\AdvancedFeaturesUI.ps1" }
            'View History'    { & "$PSScriptRoot\HistoryUI.ps1" }
            'Exit'            { break }
        }
    }
}

Show-LlamaApiPlayground
