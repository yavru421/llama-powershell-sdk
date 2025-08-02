# History UI for Llama API Playground
param()

. "$PSScriptRoot\Utils.ps1"
$historyPath = "$PSScriptRoot\..\history.json"

function Show-HistoryUI {
    [CmdletBinding()]
    param()

    if (Test-Path $historyPath) {
        try {
            $history = Get-Content $historyPath | ConvertFrom-Json

            if ($history -and $history.Count -gt 0) {
                # Create enhanced history view
                $historyView = @()
                for ($i = 0; $i -lt $history.Count; $i++) {
                    $entry = $history[$i]
                    $requestSummary = if ($entry.Request -is [array] -and $entry.Request[0].content) {
                        $entry.Request[0].content.Substring(0, [Math]::Min(100, $entry.Request[0].content.Length)) + "..."
                    } else {
                        "Request data"
                    }

                    $responseSummary = if ($entry.Response.choices -and $entry.Response.choices[0].message.content) {
                        $entry.Response.choices[0].message.content.Substring(0, [Math]::Min(100, $entry.Response.choices[0].message.content.Length)) + "..."
                    } else {
                        "Response data"
                    }

                    $tokens = if ($entry.Response.metrics) {
                        ($entry.Response.metrics | Where-Object metric -eq 'num_total_tokens' | Select-Object -ExpandProperty value)
                    } else { "N/A" }

                    $historyView += [PSCustomObject]@{
                        Index = $i + 1
                        Timestamp = $entry.Timestamp
                        RequestPreview = $requestSummary
                        ResponsePreview = $responseSummary
                        Tokens = $tokens
                        FullRequest = ($entry.Request | ConvertTo-Json -Depth 5)
                        FullResponse = ($entry.Response | ConvertTo-Json -Depth 5)
                    }
                }

                # Show history with enhanced view
                $selectedHistory = $historyView | Out-GridView -Title 'Llama API Request/Response History - Select for Details' -PassThru

                if ($selectedHistory) {
                    # Show detailed view of selected entries
                    $detailView = @()
                    foreach ($selected in $selectedHistory) {
                        $detailView += [PSCustomObject]@{
                            Type = "Request #$($selected.Index)"
                            Content = $selected.FullRequest
                            Timestamp = $selected.Timestamp
                        }
                        $detailView += [PSCustomObject]@{
                            Type = "Response #$($selected.Index)"
                            Content = $selected.FullResponse
                            Timestamp = $selected.Timestamp
                        }
                    }
                    $detailView | Out-GridView -Title 'History Details - Full Request/Response Data'
                }
            } else {
                Write-Host 'History file is empty.' -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Error reading history: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host 'No history file found. Make some API calls first!' -ForegroundColor Yellow
    }
}

Show-HistoryUI
