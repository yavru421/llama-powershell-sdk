# get_resource.ps1
$apiKey = $env:LLAMA_API_KEY
if (-not $apiKey) {
    $apiKey = "LLM|663464046470640|Fv4EkBgftoQ8b0uc91RO01me2wc"
}
$endpoint = "https://api.llama.com/v1/chat/completions"
$model = "Llama-4-Maverick-17B-128E-Instruct-FP8"
$body = @{
    model = $model
    messages = @(
        @{ role = "user"; content = "Give me a summary of the available API resources and their usage." }
    )
} | ConvertTo-Json -Depth 10
$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type" = "application/json"
    "User-Agent" = "python-requests/2.31.0"
}
try {
    $response = Invoke-WebRequest -Uri $endpoint -Method Post -Headers $headers -Body $body -ContentType "application/json"
    $json = $response.Content | ConvertFrom-Json
    if ($null -ne $json.completion_message -and $null -ne $json.completion_message.content.text -and $json.completion_message.content.text -ne "") {
        Write-Output "Test Passed: Received reply - $($json.completion_message.content.text)"
        exit 0
    } else {
        Write-Output "Test Failed: No reply in response."
        exit 1
    }
} catch {
    Write-Output "Test Failed: $($_.Exception.Message)"
    exit 2
}
