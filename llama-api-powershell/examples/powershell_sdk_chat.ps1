# powershell_sdk_chat.ps1
# Interactive Llama Chatbot about the llama-api-powershell SDK
# Created by John Daniel Dondlinger, 2025

# Import the SDK module (assumes relative path)
Import-Module "$PSScriptRoot/../src/llama_api_powershell/LlamaApi.psd1" -ErrorAction Stop

# Set up the Llama API client (uses env var or prompts for API key)
if (-not $env:LLAMA_API_KEY) {
    $env:LLAMA_API_KEY = Read-Host "Enter your LLAMA_API_KEY"
}
$client = New-LlamaClient

# Load SDK documentation for context
$readmePath = "$PSScriptRoot/../README.md"
$docText = if (Test-Path $readmePath) { Get-Content $readmePath -Raw } else { "" }

Write-Output "\nWelcome to the llama-api-powershell SDK Chatbot!"
Write-Output "Ask me anything about using the SDK, PowerShell scripting, or Llama API features. Type 'exit' to quit.\n"

# Chat loop
$history = @()
while ($true) {
    $userInput = Read-Host "You"
    if ($userInput -eq 'exit') { break }
    $history += @{ role = 'user'; content = $userInput }

    # Compose system prompt with SDK context
    $systemPrompt = @(
        "You are a helpful assistant for the llama-api-powershell SDK.",
        "Answer questions about the SDK, PowerShell scripting, and Llama API usage.",
        "Reference the following documentation when helpful:",
        $docText
    ) -join "\n"

    $messages = @(@{ role = 'system'; content = $systemPrompt }) + $history

    # Call the Llama chat API
    try {
        $response = Invoke-LlamaTool -Client $client -Model 'llama-2-7b-chat' -Messages $messages
        $reply = $response.choices[0].message.content
    } catch {
        $reply = "[Error calling Llama API: $_]"
    }
    Write-Output "LlamaSDKBot: $reply`n"
    $history += @{ role = 'assistant'; content = $reply }
}

Write-Output "Goodbye!"
