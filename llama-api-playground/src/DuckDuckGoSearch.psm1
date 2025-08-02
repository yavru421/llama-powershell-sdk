function Invoke-DuckDuckGoSearch {
    <#
    .SYNOPSIS
        Performs a DuckDuckGo web search and returns the top results.
    .PARAMETER Query
        The search query string.
    .PARAMETER Count
        The number of results to return (default: 3).
    .EXAMPLE
        Invoke-DuckDuckGoSearch -Query "PowerShell scripting" -Count 5
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Query,
        [int]$Count = 3
    )

    $url = "https://duckduckgo.com/html/?q=" + [uri]::EscapeDataString($Query)
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        $html = $response.Content
        $matches = [regex]::Matches($html, '<a rel="nofollow" class="result__a" href="([^"]+)"[^>]*>(.*?)</a>')
        $results = @()
        for ($i = 0; $i -lt [Math]::Min($Count, $matches.Count); $i++) {
            $url = $matches[$i].Groups[1].Value
            $title = ([System.Web.HttpUtility]::HtmlDecode($matches[$i].Groups[2].Value) -replace '<.*?>','').Trim()
            $results += [PSCustomObject]@{
                Title = $title
                Url = $url
            }
        }
        return $results
    } catch {
        Write-Error "DuckDuckGo search failed: $($_.Exception.Message)"
        return @()
    }
}

Export-ModuleMember -Function Invoke-DuckDuckGoSearch
