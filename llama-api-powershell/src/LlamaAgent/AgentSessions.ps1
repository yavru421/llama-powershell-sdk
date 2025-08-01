# Ensure all required wrappers are loaded before any function definitions
if ($PSScriptRoot) {
    $esWrapper = Join-Path $PSScriptRoot 'Invoke-ES.ps1'
    $exportWrapper = Join-Path $PSScriptRoot 'ESAdvanced.ps1'
    if (Test-Path $esWrapper) {
        . $esWrapper
    } else {
        Write-Error "Missing required wrapper: Invoke-ES.ps1"
    }
    if (Test-Path $exportWrapper) {
        . $exportWrapper
    } else {
        Write-Error "Missing required wrapper: ESAdvanced.ps1"
    }
}
function Start-FileSearchSession {
    <#
    .SYNOPSIS
    Highly interactive, targeted file search session.
    .DESCRIPTION
    Guides the user through a multi-turn chat to clarify search intent, builds a precise es.exe query, summarizes results, and offers next actions.
    .EXAMPLE
    Start-FileSearchSession
    #>
    [CmdletBinding()]
    param()
    Write-Output "[DEBUG] Starting Interactive FileSearchSession..."
    # Ensure Everything.exe is running for IPC
    $everythingExe = Join-Path (Get-Location) "Everything.exe"
    $startedEverything = $false
    $everythingProc = Get-Process -Name "Everything" -ErrorAction SilentlyContinue
    if (-not $everythingProc) {
        Write-Output "[INFO] Starting Everything.exe for search integration..."
        if (Test-Path $everythingExe) {
            Start-Process -FilePath $everythingExe
            Start-Sleep -Seconds 2 # Give Everything time to start
            $startedEverything = $true
        } else {
            Write-Output "[ERROR] Everything.exe not found in current directory. Please start Everything manually."
            return
        }
    }
    $folder = $null; $ext = $null; $keywords = $null; $date = $null; $size = $null; $max = 10
    Write-Output "Welcome to the Llama File Search Agent! Running automatic search..."
    # Example: auto-fill or use defaults for demo; replace with logic to infer from context or config
    $folder = $env:USERPROFILE
    $keywords = ""
    $ext = "pdf"
    $date = ""
    $size = ""
    $max = 10
    Write-Output "[DEBUG] Using folder: $folder"
    Write-Output "[DEBUG] Using ext: $ext"
    Write-Output "[DEBUG] Using keywords: $keywords"
    Write-Output "[DEBUG] Using date: $date"
    Write-Output "[DEBUG] Using size: $size"
    Write-Output "[DEBUG] Using max: $max"
    Write-Output "[DEBUG] Building query..."
    $query = ""
    if ($folder) {
        $query += "-path $folder "; Write-Output "[DEBUG] Added folder to query: -path $folder"
    }
    if ($ext) { $query += "ext:$ext "; Write-Output "[DEBUG] Added ext to query: ext:$ext" }
    if ($keywords) { $query += "$keywords "; Write-Output "[DEBUG] Added keywords to query: $keywords" }
    if ($date) { $query += "-date-modified:>$date "; Write-Output "[DEBUG] Added date to query: -date-modified:>$date" }
    if ($size) { $query += ">size:$size MB "; Write-Output "[DEBUG] Added size to query: >size:$size MB" }
    $query += "-n $max"
    Write-Output "[DEBUG] Final query: $query"
    Write-Output "[DEBUG] Invoking ES with query..."
    $results = Invoke-ES -Query $query.Trim()
    Write-Output "[DEBUG] Raw results: $results"
    $lines = $results -split "`r?`n" | Where-Object { $_ -and $_ -notmatch "^ES " -and $_ -notmatch "^Usage:" }
    Write-Output "[DEBUG] Filtered lines count: $($lines.Count)"
    if ($lines.Count -eq 0) {
        Write-Output "No files found matching your criteria."
        Write-Output "[DEBUG] No results after filtering."
    } else {
        Write-Output "Top $max results:"
        $topResults = $lines | Select-Object -First $max
        Format-ESOutput -RawOutput ($topResults -join "`n")
    }
    Write-Output "Session ended."
    Write-Output "[DEBUG] Session ended."
    if ($startedEverything) {
        Write-Output "[INFO] Stopping Everything.exe..."
        Stop-Process -Name "Everything" -Force -ErrorAction SilentlyContinue
    }
}

function Start-DiskAnalysisSession {
    <#
    .SYNOPSIS
    Interactive session for disk usage analysis or large file search.
    .EXAMPLE
    Start-DiskAnalysisSession
    #>
# Dot-source required wrappers for ES and output formatting
if ($PSScriptRoot) {
    $wrapperDir = Join-Path $PSScriptRoot '..'
    $esWrapper = Join-Path $wrapperDir 'Invoke-ES.ps1'
    $exportWrapper = Join-Path $wrapperDir 'ESAdvanced.ps1'
    if (Test-Path $esWrapper) { . $esWrapper }
    if (Test-Path $exportWrapper) { . $exportWrapper }
}
    # ...existing code...
    $choice = Read-Host "Do you want to analyze disk usage or search for large files? (analyze/search)"
    if ($choice -eq "search") {
        Write-Output "[DEBUG] No results after filtering."
        $size = Read-Host "Minimum file size in MB? (e.g. 1000 for 1GB)"
        $query = ">size:$size MB"
        $results = Invoke-ES -Query $query
        Write-Output "Large files found:"
        Format-ESOutput -RawOutput $results
    } else {
        Write-Output "Disk analysis coming soon!"
    }
}

function Start-RecentDocsSession {
    <#
    .SYNOPSIS
    Interactive session to find recently modified documents.
    .EXAMPLE
    Start-RecentDocsSession
    #>
    # ...existing code...
    $folder = Read-Host "Which folder should I search? (leave blank for all; use absolute path for best results, e.g. C:\Users\John\Documents)"
    $days = Read-Host "How many days back? (default 7)"
    if (-not $days) { $days = 7 }
    $resolvedFolder = $folder
    if ($folder -and -not ($folder -match '^[A-Za-z]:\\')) {
        $resolvedFolder = Join-Path (Get-Location) $folder
        Write-Output "[DEBUG] Resolved folder to absolute path: $resolvedFolder"
    }
    $query = "-path $resolvedFolder -date-modified:>$((Get-Date).AddDays(-$days).ToString('yyyy-MM-dd'))"
    $results = Invoke-ES -Query $query
    Write-Output "Recent documents:"
    Format-ESOutput -RawOutput $results
}
