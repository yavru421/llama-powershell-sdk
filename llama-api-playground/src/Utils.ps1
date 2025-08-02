# Utility functions for Llama API Playground

function Add-ToHistory {
    param(
        [Parameter(Mandatory)] $Request,
        [Parameter(Mandatory)] $Response
    )
    $historyPath = "$PSScriptRoot\..\history.json"
    $entry = [PSCustomObject]@{
        Timestamp = (Get-Date).ToString('s')
        Request = $Request
        Response = $Response
    }
    $history = @()
    if (Test-Path $historyPath) {
        $history = Get-Content $historyPath | ConvertFrom-Json
    }
    $history += $entry
    $history | ConvertTo-Json | Set-Content $historyPath
}
