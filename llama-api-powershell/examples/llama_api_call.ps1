# llama_api_call.ps1

# Define the API endpoint and API key
$apiKey = $env:LLAMA_API_KEY
if (-not $apiKey) {
    $apiKey = "LLM|663464046470640|Fv4EkBgftoQ8b0uc91RO01me2wc"
}
$endpoint = "https://api.llama.com/v1/chat/completions"
$model = "Llama-4-Maverick-17B-128E-Instruct-FP8"

# Define the request body
$body = @{
    model = $model
    messages = @(
        @{
            role = "user"
            content = "Hello Llama! Can you give me a quick intro?"
        }
    )
} | ConvertTo-Json -Depth 10

# Define the headers
$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type" = "application/json"
    "User-Agent" = "python-requests/2.31.0"
}

try {
    # Make the API request
    $response = Invoke-WebRequest -Uri $endpoint -Method Post -Headers $headers -Body $body -ContentType "application/json"

    # Check if the response was successful
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
