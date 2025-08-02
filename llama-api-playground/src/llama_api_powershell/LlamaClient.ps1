
function Invoke-DirectLlamaApiCall {
    <#
    .SYNOPSIS
        Example: Direct POST to Llama API using proven working pattern.
    #>
    $apiKey = "LLM|663464046470640|Fv4EkBgftoQ8b0uc91RO01me2wc"
    $endpoint = "https://api.llama.com/v1/chat/completions"
    $model = "Llama-4-Maverick-17B-128E-Instruct-FP8"
    $body = @{
        model = $model
        messages = @(
            @{ role = "user"; content = "Hello Llama! This is LlamaClient.ps1 as a script. Reply with a test message." }
        )
    } | ConvertTo-Json -Depth 10
    $headers = @{
        "Authorization" = "Bearer $apiKey"
        "Content-Type" = "application/json"
        "User-Agent" = "python-requests/2.31.0"
    }
    try {
        $response = Invoke-WebRequest -Uri $endpoint -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "Raw response content:"
        Write-Host $response.Content
    } catch {
        Write-Error "An error occurred: $_"
    }
}
