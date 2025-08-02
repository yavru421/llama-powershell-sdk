# Chat Completion UI for Llama API Playground
param()

. "$PSScriptRoot\Utils.ps1"




Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-ChatCompletionUI {
    [CmdletBinding()]
    param()

    $form = New-Object Windows.Forms.Form
    $form.Text = 'Llama Chat Completion - Input'
    $form.Size = New-Object Drawing.Size(500, 300)
    $form.StartPosition = 'CenterScreen'

    $lblPrompt = New-Object Windows.Forms.Label
    $lblPrompt.Text = 'Prompt:'
    $lblPrompt.Location = New-Object Drawing.Point(10,20)
    $lblPrompt.Size = New-Object Drawing.Size(80,20)
    $form.Controls.Add($lblPrompt)

    $txtPrompt = New-Object Windows.Forms.TextBox
    $txtPrompt.Location = New-Object Drawing.Point(100,20)
    $txtPrompt.Size = New-Object Drawing.Size(370,20)
    $txtPrompt.Text = ''
    $form.Controls.Add($txtPrompt)

    $lblModel = New-Object Windows.Forms.Label
    $lblModel.Text = 'Model:'
    $lblModel.Location = New-Object Drawing.Point(10,60)
    $lblModel.Size = New-Object Drawing.Size(80,20)
    $form.Controls.Add($lblModel)

    $txtModel = New-Object Windows.Forms.TextBox
    $txtModel.Location = New-Object Drawing.Point(100,60)
    $txtModel.Size = New-Object Drawing.Size(370,20)
    $txtModel.Text = 'Llama-4-Maverick-17B-128E-Instruct-FP8'
    $form.Controls.Add($txtModel)

    $lblSystem = New-Object Windows.Forms.Label
    $lblSystem.Text = 'System Message:'
    $lblSystem.Location = New-Object Drawing.Point(10,100)
    $lblSystem.Size = New-Object Drawing.Size(100,20)
    $form.Controls.Add($lblSystem)

    $txtSystem = New-Object Windows.Forms.TextBox
    $txtSystem.Location = New-Object Drawing.Point(120,100)
    $txtSystem.Size = New-Object Drawing.Size(350,20)
    $txtSystem.Text = 'You are a helpful assistant.'
    $form.Controls.Add($txtSystem)

    $btnOK = New-Object Windows.Forms.Button
    $btnOK.Text = 'Send'
    $btnOK.Location = New-Object Drawing.Point(200,150)
    $btnOK.Size = New-Object Drawing.Size(80,30)
    $btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $btnOK
    $form.Controls.Add($btnOK)

    $result = $form.ShowDialog()
    if ($result -ne [System.Windows.Forms.DialogResult]::OK) { return }

    $prompt = $txtPrompt.Text
    $model = $txtModel.Text
    $systemMsg = $txtSystem.Text

    if (-not $prompt) {
        [System.Windows.Forms.MessageBox]::Show('Please enter a prompt.','Input Required',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $messages = @()
    if ($systemMsg -and $systemMsg -ne 'You are a helpful assistant.') {
        $messages += @{ role = 'system'; content = $systemMsg }
    }
    $messages += @{ role = 'user'; content = $prompt }

    try {
        Write-Host 'Sending request to Llama API...' -ForegroundColor Green
        $response = Invoke-LlamaApiRequest -Messages $messages -Model $model

        if ($response -and $response.choices -and $response.choices[0]) {
            $result = @(
                [PSCustomObject]@{
                    Type = 'Input'
                    Content = $prompt
                    Metadata = "Model: $model"
                },
                [PSCustomObject]@{
                    Type = 'Output'
                    Content = $response.choices[0].message.content
                    Metadata = "Tokens: $($response.metrics | Where-Object metric -eq 'num_total_tokens' | Select-Object -ExpandProperty value)"
                }
            )

            Add-ToHistory -Request $messages -Response $response
            $result | Out-GridView -Title 'Llama Chat Completion - Results'
        } else {
            Write-Host 'No response received from API.' -ForegroundColor Red
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Show-ChatCompletionUI
