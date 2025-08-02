# Moderation UI for Llama API Playground
param()

. "$PSScriptRoot\Utils.ps1"



function Show-ModerationUI {
    [CmdletBinding()]
    param()

    # Create input form with editable fields
    $inputForm = @(
        [PSCustomObject]@{
            Field = 'TextToModerate';
            Value = 'Enter text to check for safety issues...';
            Description = 'Text content to moderate'
        },
        [PSCustomObject]@{
            Field = 'ModerationLevel';
            Value = 'Standard';
            Description = 'Moderation strictness (Standard/Strict/Lenient)'
        }
    )

    $userInput = $inputForm | Out-GridView -Title 'Llama Moderation - Configure and Submit' -PassThru
    if (-not $userInput -or $userInput.Count -eq 0) { return }

    # Extract values from form
    $textToModerate = ($userInput | Where-Object Field -eq 'TextToModerate').Value
    $moderationLevel = ($userInput | Where-Object Field -eq 'ModerationLevel').Value

    if (-not $textToModerate -or $textToModerate -eq 'Enter text to check for safety issues...') {
        Write-Host 'No valid text provided for moderation.' -ForegroundColor Yellow
        return
    }

    # Build moderation prompt
    $moderationPrompt = "Please analyze the following text for safety issues, harmful content, bias, or inappropriate material. Moderation level: $moderationLevel. Provide a detailed assessment with safety score (1-10, where 10 is completely safe) and specific concerns if any.`n`nText to moderate: `"$textToModerate`""
    $messages = @(@{ role = 'user'; content = $moderationPrompt })

    try {
        Write-Host 'Analyzing content with Llama moderation...' -ForegroundColor Green
        $response = Invoke-LlamaApiRequest -Messages $messages

        if ($response -and $response.choices -and $response.choices[0]) {
            $result = @(
                [PSCustomObject]@{
                    Type = 'Original Text'
                    Content = $textToModerate
                    Metadata = "Length: $($textToModerate.Length) chars"
                },
                [PSCustomObject]@{
                    Type = 'Moderation Analysis'
                    Content = $response.choices[0].message.content
                    Metadata = "Level: $moderationLevel"
                }
            )

            Add-ToHistory -Request $messages -Response $response
            $result | Out-GridView -Title 'Llama Moderation - Results'
        } else {
            Write-Host 'No response received from moderation API.' -ForegroundColor Red
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Show-ModerationUI
