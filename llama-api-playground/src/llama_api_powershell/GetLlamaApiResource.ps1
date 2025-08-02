function Get-LlamaApiResource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ApiKey = $env:LLAMA_API_KEY,
        [Parameter(Mandatory=$false)]
        [string]$Model = "Llama-4-Maverick-17B-128E-Instruct-FP8"
    )
    if (-not $ApiKey) {
        throw "No API key provided. Set the LLAMA_API_KEY environment variable or pass -ApiKey."
    }
    $endpoint = "https://api.llama.com/v1/chat/completions"
    $messages = @(
        @{ role = "user"; content = "Give me a summary of the available API resources and their usage." }
    )
    $body = @{ model = $Model; messages = $messages } | ConvertTo-Json -Depth 10
    $headers = @{
        "Authorization" = "Bearer $ApiKey"
        "Content-Type" = "application/json"
        "User-Agent" = "LlamaApiPS/1.0"
    }
    try {
        $response = Invoke-WebRequest -Uri $endpoint -Method Post -Headers $headers -Body $body -ContentType "application/json"
        $json = $response.Content | ConvertFrom-Json
        return $json
    } catch {
        Write-Error "Get-LlamaApiResource failed: $($_.Exception.Message)"
        return $null
    }
}
