function Invoke-ES {
    <#
    .SYNOPSIS
    Runs es.exe with the specified query arguments and returns the output.
    .DESCRIPTION
    This function wraps the Everything es.exe CLI tool, executes it with the provided arguments, and returns the output as a string.
    .PARAMETER Query
    The arguments to pass to es.exe (e.g., "-help" or a search query).
    .EXAMPLE
    Invoke-ES -Query "-help"
    .NOTES
    Throws if es.exe is not found in repo root.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Query
    )
    $exePath = Join-Path $PSScriptRoot '..\..\..' 'es.exe'
    if (-not (Test-Path $exePath)) {
        Write-Error "es.exe not found in repo root. Please ensure Everything CLI is present."
        return $null
    }
    try {
        $output = & $exePath $Query 2>&1
        return $output
    } catch {
        Write-Error "Failed to run es.exe: $($_.Exception.Message)"
        return $null
    }
}

function Invoke-ES {
    <#
    .SYNOPSIS
    Runs es.exe with the specified query arguments and returns the output.
    .DESCRIPTION
    This function wraps the Everything es.exe CLI tool, executes it with the provided arguments, and returns the output as a string.
    .PARAMETER Query
    The arguments to pass to es.exe (e.g., "-help" or a search query).
    .EXAMPLE
    Invoke-ES -Query "-help"
    .NOTES
    Throws if es.exe is not found in the repo root.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Query
    )
    $exePath = Join-Path $PSScriptRoot '..\..\..' 'es.exe'
    if (-not (Test-Path $exePath)) {
        Write-Error "es.exe not found in repo root. Please ensure Everything CLI is present."
        return $null
    }
    try {
        $output = & $exePath $Query 2>&1
        return $output
    } catch {
        Write-Error "Failed to run es.exe: $($_.Exception.Message)"
        return $null
    }
}
