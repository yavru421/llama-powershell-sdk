
function Start-LlamaAgent {
    <#
    .SYNOPSIS
    Starts the interactive Llama agent loop for tool calling and chat.
    .DESCRIPTION
    This function runs an interactive chat loop, parses agent tool calls (e.g., #file:es.exe <args>), executes the requested tool, and returns output.
    .PARAMETER InitialPrompt
    The initial prompt to display to the user.
    .EXAMPLE
    Start-LlamaAgent
    .NOTES
    Type 'exit' to quit the agent loop.
    #>
    [CmdletBinding()]
    param(
        [string]$InitialPrompt = "How can I help you?"
    )
    $messages = @(@{role='system';content='You are a PowerShell agent. To use a tool, reply with #file:es.exe <args>.'})
    while ($true) {
        $userInput = Read-Host $InitialPrompt
        if ($userInput -eq 'exit') { break }
        $messages += @{role='user';content=$userInput}
        try {
            $response = Invoke-LlamaApiRequest -Messages $messages
            $reply = $response.completion_message.content.text
            Write-Output "Llama: $reply"
            if ($reply -match '#file:es.exe (.+)') {
                $toolArgs = $Matches[1]
                Write-Output "[Agent] Running es.exe with args: $toolArgs"
                $toolOutput = Invoke-ES -Query $toolArgs
                Write-Output "[es.exe output]: $toolOutput"
                $messages += @{role='assistant';content="[es.exe output]: $toolOutput"}
            } else {
                $messages += @{role='assistant';content=$reply}
            }
        } catch {
            Write-Error "Agent error: $($_.Exception.Message)"
        }
    }
}
