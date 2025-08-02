# List Models UI for Llama API Playground
param()

. "$PSScriptRoot\Utils.ps1"



function Show-ListModelsUI {
    [CmdletBinding()]
    param()

    # Create options form
    $optionsForm = @(
        [PSCustomObject]@{
            Field = 'DetailLevel';
            Value = 'Detailed';
            Description = 'Amount of detail (Summary/Detailed/Technical)'
        },
        [PSCustomObject]@{
            Field = 'Focus';
            Value = 'All Models';
            Description = 'Focus area (All Models/Chat Models/Code Models/Multimodal)'
        }
    )

    $userInput = $optionsForm | Out-GridView -Title 'Llama Models - Configure Request' -PassThru
    if (-not $userInput -or $userInput.Count -eq 0) {
        # Use defaults if no selection
        $detailLevel = 'Detailed'
        $focus = 'All Models'
    } else {
        $detailLevel = ($userInput | Where-Object Field -eq 'DetailLevel').Value
        $focus = ($userInput | Where-Object Field -eq 'Focus').Value
    }

    # Build models query prompt
    $modelsPrompt = "Please provide a $detailLevel overview of available Llama models, focusing on: $focus. Include model names, capabilities, use cases, and key specifications. Format the response in a clear, structured way."
    $messages = @(@{ role = 'user'; content = $modelsPrompt })

    try {
        Write-Host 'Fetching Llama models information...' -ForegroundColor Green
        $response = Invoke-LlamaApiRequest -Messages $messages

        if ($response -and $response.choices -and $response.choices[0]) {
            $result = @(
                [PSCustomObject]@{
                    Category = 'Query Parameters'
                    Information = "Detail Level: $detailLevel | Focus: $focus"
                    Source = 'User Input'
                },
                [PSCustomObject]@{
                    Category = 'Available Models'
                    Information = $response.choices[0].message.content
                    Source = 'Llama API Response'
                }
            )

            Add-ToHistory -Request $messages -Response $response
            $result | Out-GridView -Title 'Llama Models - Information'
        } else {
            Write-Host 'No response received from models API.' -ForegroundColor Red
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Show-ListModelsUI
