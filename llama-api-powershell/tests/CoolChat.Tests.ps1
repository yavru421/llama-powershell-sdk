# CoolChat.Tests.ps1
# Interactive chat test using the Llama API PowerShell SDK

# Import the main module if needed (uncomment if required)
# Import-Module ../src/llama_api_powershell/LlamaClient.ps1

function Start-CoolChat {
    $apiKey = $env:LLAMA_API_KEY
    if (-not $apiKey) {
        $apiKey = "LLM|663464046470640|Fv4EkBgftoQ8b0uc91RO01me2wc"
    }
    $endpoint = "https://api.llama.com/v1/chat/completions"
    $model = "Llama-4-Maverick-17B-128E-Instruct-FP8"
    Write-Output "Welcome to CoolChat! Type 'exit' to quit."
    $history = @()
    while ($true) {
        $userInput = Read-Host "You"
        if ($userInput -eq 'exit') { break }
        $history += @{ role = "user"; content = $userInput }
        $body = @{ model = $model; messages = $history } | ConvertTo-Json -Depth 10
        $headers = @{ "Authorization" = "Bearer $apiKey"; "Content-Type" = "application/json"; "User-Agent" = "CoolChat/1.0" }
        try {
            $response = Invoke-WebRequest -Uri $endpoint -Method Post -Headers $headers -Body $body -ContentType "application/json"
            $json = $response.Content | ConvertFrom-Json
            $reply = $json.completion_message.content.text
            Write-Output "Llama: $reply"
            $history += @{ role = "assistant"; content = $reply }
        } catch {
            Write-Output "Error: $($_.Exception.Message)"
        }
    }
    Write-Output "Goodbye!"
}

# Always run the chat interactively when this script is executed
Start-CoolChat
