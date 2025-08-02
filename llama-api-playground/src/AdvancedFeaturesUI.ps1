# Advanced Playground Features
param()

. "$PSScriptRoot\Utils.ps1"

function Show-AdvancedFeaturesUI {
    [CmdletBinding()]
    param()

    $advancedMenu = @(
        [PSCustomObject]@{ Feature = 'Multi-Turn Chat'; Description = 'Conversation with context history' },
        [PSCustomObject]@{ Feature = 'Batch Processing'; Description = 'Process multiple prompts at once' },
        [PSCustomObject]@{ Feature = 'Model Comparison'; Description = 'Compare responses from different models' },
        [PSCustomObject]@{ Feature = 'Export Results'; Description = 'Export history and results to file' },
        [PSCustomObject]@{ Feature = 'Import Config'; Description = 'Load predefined prompt templates' }
    )

    $choice = $advancedMenu | Out-GridView -Title 'Advanced Playground Features' -PassThru
    if (-not $choice) { return }

    switch ($choice.Feature) {
        'Multi-Turn Chat' { Start-MultiTurnChat }
        'Batch Processing' { Start-BatchProcessing }
        'Model Comparison' { Start-ModelComparison }
        'Export Results' { Export-PlaygroundResults }
        'Import Config' { Import-PlaygroundConfig }
    }
}

function Start-MultiTurnChat {
    $conversation = @()
    $conversationHistory = @()

    while ($true) {
        $inputForm = @(
            [PSCustomObject]@{
                Field = 'Message';
                Value = 'Type your message (or "quit" to exit)...';
                Description = 'Your message to continue the conversation'
            }
        )

        $userInput = $inputForm | Out-GridView -Title "Multi-Turn Chat - Turn $($conversation.Count + 1)" -PassThru
        if (-not $userInput) { break }

        $message = ($userInput | Where-Object Field -eq 'Message').Value
        if ($message -eq 'quit' -or $message -eq 'Type your message (or "quit" to exit)...') { break }

        # Add user message to conversation
        $conversation += @{ role = 'user'; content = $message }

        try {
            $response = Invoke-LlamaApiRequest -Messages $conversation
            if ($response -and $response.choices -and $response.choices[0]) {
                # Add assistant response to conversation
                $assistantMessage = $response.choices[0].message.content
                $conversation += @{ role = 'assistant'; content = $assistantMessage }

                # Show current exchange
                $exchangeView = @(
                    [PSCustomObject]@{
                        Turn = $conversation.Count / 2
                        Type = 'User'
                        Message = $message
                    },
                    [PSCustomObject]@{
                        Turn = $conversation.Count / 2
                        Type = 'Assistant'
                        Message = $assistantMessage
                    }
                )
                $exchangeView | Out-GridView -Title "Chat Turn $($conversation.Count / 2)"

                Add-ToHistory -Request $conversation -Response $response
            }
        } catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

function Start-BatchProcessing {
    $batchForm = @(
        [PSCustomObject]@{
            Field = 'Prompts';
            Value = 'Prompt 1|Prompt 2|Prompt 3';
            Description = 'Multiple prompts separated by |'
        }
    )

    $userInput = $batchForm | Out-GridView -Title 'Batch Processing - Enter Prompts' -PassThru
    if (-not $userInput) { return }

    $promptsText = ($userInput | Where-Object Field -eq 'Prompts').Value
    $prompts = $promptsText -split '\|'

    $results = @()
    for ($i = 0; $i -lt $prompts.Count; $i++) {
        $prompt = $prompts[$i].Trim()
        if ($prompt) {
            try {
                Write-Host "Processing prompt $($i + 1) of $($prompts.Count)..." -ForegroundColor Green
                $messages = @(@{ role = 'user'; content = $prompt })
                $response = Invoke-LlamaApiRequest -Messages $messages

                if ($response -and $response.choices -and $response.choices[0]) {
                    $results += [PSCustomObject]@{
                        Batch = $i + 1
                        Prompt = $prompt
                        Response = $response.choices[0].message.content
                        Tokens = ($response.metrics | Where-Object metric -eq 'num_total_tokens' | Select-Object -ExpandProperty value)
                    }
                    Add-ToHistory -Request $messages -Response $response
                }
            } catch {
                $results += [PSCustomObject]@{
                    Batch = $i + 1
                    Prompt = $prompt
                    Response = "ERROR: $($_.Exception.Message)"
                    Tokens = 0
                }
            }
        }
    }

    $results | Out-GridView -Title 'Batch Processing Results'
}

Show-AdvancedFeaturesUI
