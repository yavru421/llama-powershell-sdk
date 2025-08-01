function Export-ESResults {
    <#
    .SYNOPSIS
    Export ES search results to a file.
    .PARAMETER SearchText
    The search string.
    .PARAMETER OutFile
    Output file path.
    .PARAMETER Format
    Export format: 'csv', 'txt', 'tsv'.
    .EXAMPLE
    Export-ESResults -SearchText 'PowerShell' -OutFile 'results.csv' -Format 'csv'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SearchText,
        [Parameter(Mandatory=$true)]
        [string]$OutFile,
        [ValidateSet("csv","txt","tsv")]
        [string]$Format = "csv"
    )
    $query = "$SearchText -export-$Format $OutFile"
    $results = Invoke-ES -Query $query
    Write-Output "Exported results to $OutFile"
}

function Format-ESOutput {
    <#
    .SYNOPSIS
    Format raw ES output for user-friendly display.
    .PARAMETER RawOutput
    The raw output from es.exe.
    .EXAMPLE
    Format-ESOutput -RawOutput $results
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$RawOutput
    )
    if ($RawOutput -match "^Error") {
        Write-Error $RawOutput
        return
    }
    $lines = $RawOutput -split "`r?`n"
    $lines | Where-Object { $_ -and $_ -notmatch "^ES " -and $_ -notmatch "^Usage:" } | ForEach-Object {
        Write-Output $_
    }
}
function Search-ESByExtension {
    <#
    .SYNOPSIS
    Search for files by extension using es.exe.
    .PARAMETER Extension
    The file extension to search for (e.g., 'txt').
    .PARAMETER MaxResults
    Maximum number of results to return.
    .EXAMPLE
    Search-ESByExtension -Extension 'ps1' -MaxResults 20
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Extension,
        [int]$MaxResults = 10
    )
    $query = "ext:$Extension -n $MaxResults"
    $results = Invoke-ES -Query $query
    Format-ESOutput -RawOutput $results
}

function Search-ESSorted {
    <#
    .SYNOPSIS
    Search for files and sort results using es.exe.
    .PARAMETER SearchText
    The search string.
    .PARAMETER SortBy
    Sort by 'name', 'size', 'date-modified', etc.
    .EXAMPLE
    Search-ESSorted -SearchText 'PowerShell' -SortBy 'date-modified'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SearchText,
        [ValidateSet("name","size","date-modified")]
        [string]$SortBy = "name"
    )
    $query = "$SearchText -sort $SortBy"
    $results = Invoke-ES -Query $query
    Format-ESOutput -RawOutput $results
}

function Export-ESResults {
    <#
    .SYNOPSIS
    Export ES search results to a file.
    .PARAMETER SearchText
    The search string.
    .PARAMETER OutFile
    Output file path.
    .PARAMETER Format
    Export format: 'csv', 'txt', 'tsv'.
    .EXAMPLE
    Export-ESResults -SearchText 'PowerShell' -OutFile 'results.csv' -Format 'csv'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SearchText,
        [Parameter(Mandatory=$true)]
        [string]$OutFile,
        [ValidateSet("csv","txt","tsv")]
        [string]$Format = "csv"
    )
    $query = "$SearchText -export-$Format $OutFile"
    $results = Invoke-ES -Query $query
    Write-Output "Exported results to $OutFile"
}

function Invoke-ESAdvancedSearch {
    <#
    .SYNOPSIS
    Perform a meta-programmable ES search with multiple options.
    .PARAMETER SearchText
    The search string.
    .PARAMETER Extension
    File extension filter.
    .PARAMETER Path
    Folder path filter.
    .PARAMETER MaxResults
    Maximum results.
    .PARAMETER SortBy
    Sort by column.
    .EXAMPLE
    Invoke-ESAdvancedSearch -SearchText 'PowerShell' -Extension 'ps1' -Path 'C:\Scripts' -MaxResults 50 -SortBy 'date-modified'
    #>
    [CmdletBinding()]
    param(
        [string]$SearchText,
        [string]$Extension,
        [string]$Path,
        [int]$MaxResults = 100,
        [string]$SortBy = "name"
    )
    $query = ""
    if ($SearchText) { $query += "$SearchText " }
    if ($Extension) { $query += "ext:$Extension " }
    if ($Path) { $query += "-path $Path " }
    $query += "-n $MaxResults -sort $SortBy"
    $results = Invoke-ES -Query $query.Trim()
    Format-ESOutput -RawOutput $results
}

function Format-ESOutput {
    <#
    .SYNOPSIS
    Format raw ES output for user-friendly display.
    .PARAMETER RawOutput
    The raw output from es.exe.
    .EXAMPLE
    Format-ESOutput -RawOutput $results
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$RawOutput
    )
    if ($RawOutput -match "^Error") {
        Write-Error $RawOutput
        return
    }
    $lines = $RawOutput -split "`r?`n"
    $lines | Where-Object { $_ -and $_ -notmatch "^ES " -and $_ -notmatch "^Usage:" } | ForEach-Object {
        Write-Output $_
    }
}
