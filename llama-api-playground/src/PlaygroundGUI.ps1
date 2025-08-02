# Ensure Add-Type is at the very top and remove unnecessary [void][System.Reflection.Assembly]::LoadWithPartialName lines
# --- Ensure Windows Forms and Drawing types are loaded at the very top ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ...existing code...


# --- GUI FORM CREATION ---
$form = New-Object Windows.Forms.Form
$form.Text = 'Llama API Playground'
$form.Size = New-Object Drawing.Size(820, 660)
$form.StartPosition = 'CenterScreen'
# Llama API Playground - Unified GUI


# --- API Key Check ---
$apiKey = [Environment]::GetEnvironmentVariable('LLAMA_API_KEY','User')
if (-not $apiKey) {
    [System.Windows.Forms.MessageBox]::Show('LLAMA_API_KEY environment variable is not set. Please set your API key before using the playground.','API Key Missing',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
    exit 1
}

# --- Execution Policy Bypass ---
# If the current execution policy is too restrictive, re-launch the script with a bypassed policy for this process only.
if ((Get-ExecutionPolicy) -eq 'Restricted') {
    Write-Host "Execution policy is Restricted. Re-launching with '-ExecutionPolicy Bypass'..." -ForegroundColor Yellow
    try {
        # Get the full path to the current script and re-launch PowerShell with the bypass flag
        PowerShell.exe -ExecutionPolicy Bypass -File "$($MyInvocation.MyCommand.Path)"
        # Exit the current restricted session
        exit
    } catch {
        Write-Error "Failed to re-launch with bypassed execution policy. Please run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
        exit
    }
}
# --- End Execution Policy Bypass ---

# --- Robust Module Import (EXE-friendly, auto-copy if needed) ---
# --- Robust Module Import (EXE-friendly, auto-copy if needed) ---
$exeDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$llamaModuleDir = Join-Path $exeDir 'llama_api_powershell'
$llamaModule = Join-Path $llamaModuleDir 'LlamaApi.psm1'
Write-Host "[DEBUG] Checking for LlamaApi.psm1 at: $llamaModule" -ForegroundColor Yellow
if (-not (Test-Path $llamaModule)) {
    # Try to copy from correct dev location if running from source
    $devModuleDir = Resolve-Path '..\llama-api-powershell\src\llama_api_powershell' -ErrorAction SilentlyContinue
    if ($devModuleDir) {
        Copy-Item -Path $devModuleDir -Destination $llamaModuleDir -Recurse -Force
    }
}
if (-not (Test-Path $llamaModule)) {
    Write-Error "Could not find LlamaApi.psm1. Please check the SDK path. Checked: $llamaModule"
    exit 1
}
Import-Module $llamaModule -Force
if (Test-Path (Join-Path $exeDir 'DuckDuckGoSearch.psm1')) {
    Import-Module (Join-Path $exeDir 'DuckDuckGoSearch.psm1') -Force
}
# --- End Robust Module Import ---
$form.BackColor = [System.Drawing.Color]::FromArgb(30,30,40)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Regular)

# Add TabControl
$tabControl = New-Object Windows.Forms.TabControl
$tabControl.Location = New-Object Drawing.Point(0,0)
$tabControl.Size = New-Object Drawing.Size(810,660)
$tabControl.Font = New-Object System.Drawing.Font('Segoe UI', 11)
$tabControl.BackColor = [System.Drawing.Color]::FromArgb(30,30,40)
$tabControl.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($tabControl)

# Playground Tab
$tabPlayground = New-Object Windows.Forms.TabPage
$tabPlayground.Text = 'Playground'
$tabPlayground.BackColor = [System.Drawing.Color]::FromArgb(30,30,40)
$tabPlayground.ForeColor = [System.Drawing.Color]::White
$tabControl.TabPages.Add($tabPlayground)


# Script Lab Tab (for script generation/execution)
$tabScriptLab = New-Object Windows.Forms.TabPage
$tabScriptLab.Text = 'Script Lab'
$tabScriptLab.BackColor = [System.Drawing.Color]::FromArgb(30,30,40)
$tabScriptLab.ForeColor = [System.Drawing.Color]::White
$tabControl.TabPages.Add($tabScriptLab)

# Script input label
$lblScriptLab = New-Object Windows.Forms.Label
$lblScriptLab.Text = 'Enter PowerShell Script:'
$lblScriptLab.Font = New-Object System.Drawing.Font('Segoe UI', 13, [System.Drawing.FontStyle]::Bold)
$lblScriptLab.ForeColor = [System.Drawing.Color]::DeepSkyBlue
$lblScriptLab.Location = New-Object Drawing.Point(20,20)
$lblScriptLab.Size = New-Object Drawing.Size(350,30)
$tabScriptLab.Controls.Add($lblScriptLab)

# Script input box
$txtScriptLab = New-Object Windows.Forms.TextBox
$txtScriptLab.Location = New-Object Drawing.Point(20,60)
$txtScriptLab.Size = New-Object Drawing.Size(750,180)
$txtScriptLab.Multiline = $true
$txtScriptLab.ScrollBars = 'Vertical'
$txtScriptLab.BackColor = [System.Drawing.Color]::FromArgb(40,40,55)
$txtScriptLab.ForeColor = [System.Drawing.Color]::White
$txtScriptLab.BorderStyle = 'FixedSingle'
$txtScriptLab.Font = New-Object System.Drawing.Font('Consolas', 11)
$tabScriptLab.Controls.Add($txtScriptLab)

# Run Script button
$btnRunScriptLab = New-Object Windows.Forms.Button
$btnRunScriptLab.Text = 'Run Script'
$btnRunScriptLab.Location = New-Object Drawing.Point(20,250)
$btnRunScriptLab.Size = New-Object Drawing.Size(120,40)
$btnRunScriptLab.BackColor = [System.Drawing.Color]::DeepSkyBlue
$btnRunScriptLab.ForeColor = [System.Drawing.Color]::White
$btnRunScriptLab.FlatStyle = 'Flat'
$btnRunScriptLab.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$tabScriptLab.Controls.Add($btnRunScriptLab)

# Script output label
$lblScriptLabOut = New-Object Windows.Forms.Label
$lblScriptLabOut.Text = 'Output:'
$lblScriptLabOut.Location = New-Object Drawing.Point(20,300)
$lblScriptLabOut.Size = New-Object Drawing.Size(100,24)
$lblScriptLabOut.ForeColor = [System.Drawing.Color]::White
$lblScriptLabOut.BackColor = [System.Drawing.Color]::Transparent
$tabScriptLab.Controls.Add($lblScriptLabOut)

# Script output box
$txtScriptLabOut = New-Object Windows.Forms.RichTextBox
$txtScriptLabOut.Location = New-Object Drawing.Point(20,330)
$txtScriptLabOut.Size = New-Object Drawing.Size(750,260)
$txtScriptLabOut.ReadOnly = $true
$txtScriptLabOut.BackColor = [System.Drawing.Color]::FromArgb(20,20,30)
$txtScriptLabOut.ForeColor = [System.Drawing.Color]::White
$txtScriptLabOut.Font = New-Object System.Drawing.Font('Consolas', 12)
$txtScriptLabOut.BorderStyle = 'FixedSingle'
$tabScriptLab.Controls.Add($txtScriptLabOut)

# Run Script logic
$btnRunScriptLab.Add_Click({
    $script = $txtScriptLab.Text
    $txtScriptLabOut.Clear()
    if (-not $script) {
        $txtScriptLabOut.SelectionColor = [System.Drawing.Color]::Orange
        $txtScriptLabOut.AppendText('No script entered.')
        return
    }
    try {
        $output = Invoke-Command -ScriptBlock ([ScriptBlock]::Create($script))
        if ($output) {
            $txtScriptLabOut.SelectionColor = [System.Drawing.Color]::White
            $txtScriptLabOut.AppendText(($output | Out-String))
        } else {
            $txtScriptLabOut.SelectionColor = [System.Drawing.Color]::LightGray
            $txtScriptLabOut.AppendText('No output.')
        }
    } catch {
        $txtScriptLabOut.SelectionColor = [System.Drawing.Color]::OrangeRed
        $txtScriptLabOut.AppendText("Error: $($_.Exception.Message)")
    }
})

# Coming Soon Tab

$tabComingSoon = New-Object Windows.Forms.TabPage
$tabComingSoon.Text = 'Coming Soon'
$tabComingSoon.BackColor = [System.Drawing.Color]::FromArgb(30,30,40)
$tabComingSoon.ForeColor = [System.Drawing.Color]::White
$tabControl.TabPages.Add($tabComingSoon)

# Add Coming Soon features UI
$lblComingSoon = New-Object Windows.Forms.Label
$lblComingSoon.Text = '🚧 Advanced Features Coming Soon!'
$lblComingSoon.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$lblComingSoon.ForeColor = [System.Drawing.Color]::Orange
$lblComingSoon.Location = New-Object Drawing.Point(20,20)
$lblComingSoon.Size = New-Object Drawing.Size(600,40)
$tabComingSoon.Controls.Add($lblComingSoon)

$y = 80
function Add-ComingSoonStub {
    param($title, $desc)
    $lbl = New-Object Windows.Forms.Label
    $lbl.Text = $title
    $lbl.Font = New-Object System.Drawing.Font('Segoe UI', 13, [System.Drawing.FontStyle]::Bold)
    $lbl.ForeColor = [System.Drawing.Color]::DeepSkyBlue
    $lbl.Location = New-Object Drawing.Point(30, $y)
    $lbl.Size = New-Object Drawing.Size(350,30)
    $tabComingSoon.Controls.Add($lbl)
    $y += 32
    $descLbl = New-Object Windows.Forms.Label
    $descLbl.Text = $desc
    $descLbl.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $descLbl.ForeColor = [System.Drawing.Color]::White
    $descLbl.Location = New-Object Drawing.Point(50, $y)
    $descLbl.Size = New-Object Drawing.Size(700,40)
    $tabComingSoon.Controls.Add($descLbl)
    $y += 48
    $btn = New-Object Windows.Forms.Button
    $btn.Text = 'Coming Soon'
    $btn.Location = New-Object Drawing.Point(50, $y)
    $btn.Size = New-Object Drawing.Size(120,28)
    $btn.Enabled = $false
    $tabComingSoon.Controls.Add($btn)
    $y += 38
}

Add-ComingSoonStub 'Secure Sandboxing' 'Run scripts in a secure, isolated PowerShell environment (JEA, Constrained Language Mode, or containers) for maximum safety.'
Add-ComingSoonStub 'Live System/Cloud Automation' 'Full automation of local/remote systems and cloud APIs (Azure, AWS, etc) with advanced permissions and auditing.'
Add-ComingSoonStub 'Multi-Modal Workflows' 'Accept and process files, images, or voice input, and let the model script PowerShell to analyze or transform them.'
Add-ComingSoonStub 'Plugin/Tool Marketplace' 'Discover, install, and use new PowerShell modules or scripts as tools at runtime.'
Add-ComingSoonStub 'Model-Driven GUI Automation' 'Generate and run PowerShell code that automates Windows GUI actions (UIAutomation, WASP, etc).'
Add-ComingSoonStub 'Real-Time Collaboration' 'Multi-user mode: interact with the same playground session, sharing state, chat, and scripts.'
Add-ComingSoonStub 'Self-Healing/Auto-Repair' 'Automatic diagnosis and repair of script or environment issues, learning from past fixes.'
Add-ComingSoonStub 'Full Automation Pipelines' 'Design, visualize, and execute end-to-end automation pipelines directly in the playground.'

# Optional: Add a logo or title to Playground tab
$lblTitle = New-Object Windows.Forms.Label
$lblTitle.Text = '🦙 Llama API Playground'
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::DeepSkyBlue
$lblTitle.BackColor = [System.Drawing.Color]::Transparent
$lblTitle.Location = New-Object Drawing.Point(20,10)
$lblTitle.Size = New-Object Drawing.Size(400,40)
$tabPlayground.Controls.Add($lblTitle)


# Prompt label and textbox
$lblPrompt = New-Object Windows.Forms.Label
$lblPrompt.Text = 'Prompt:'
$lblPrompt.Location = New-Object Drawing.Point(20,60)
$lblPrompt.Size = New-Object Drawing.Size(70,24)
$lblPrompt.ForeColor = [System.Drawing.Color]::White
$lblPrompt.BackColor = [System.Drawing.Color]::Transparent
$tabPlayground.Controls.Add($lblPrompt)

$txtPrompt = New-Object Windows.Forms.TextBox
$txtPrompt.Location = New-Object Drawing.Point(100,60)
$txtPrompt.Size = New-Object Drawing.Size(670,40)
$txtPrompt.Multiline = $true
$txtPrompt.ScrollBars = 'Vertical'
$txtPrompt.BackColor = [System.Drawing.Color]::FromArgb(40,40,55)
$txtPrompt.ForeColor = [System.Drawing.Color]::White
$txtPrompt.BorderStyle = 'FixedSingle'
$txtPrompt.Font = New-Object System.Drawing.Font('Consolas', 11)
$tabPlayground.Controls.Add($txtPrompt)


# System prompt label and textbox
$lblSystem = New-Object Windows.Forms.Label
$lblSystem.Text = 'System Prompt:'
$lblSystem.Location = New-Object Drawing.Point(20,110)
$lblSystem.Size = New-Object Drawing.Size(120,24)
$lblSystem.ForeColor = [System.Drawing.Color]::White
$lblSystem.BackColor = [System.Drawing.Color]::Transparent
$tabPlayground.Controls.Add($lblSystem)

$txtSystem = New-Object Windows.Forms.TextBox
$txtSystem.Location = New-Object Drawing.Point(150,110)
$txtSystem.Size = New-Object Drawing.Size(620,24)
$txtSystem.Text = 'You are a helpful assistant.'
$txtSystem.BackColor = [System.Drawing.Color]::FromArgb(40,40,55)
$txtSystem.ForeColor = [System.Drawing.Color]::White
$txtSystem.BorderStyle = 'FixedSingle'
$tabPlayground.Controls.Add($txtSystem)


# Model label and dropdown
$lblModel = New-Object Windows.Forms.Label
$lblModel.Text = 'Model:'
$lblModel.Location = New-Object Drawing.Point(20,150)
$lblModel.Size = New-Object Drawing.Size(60,24)
$lblModel.ForeColor = [System.Drawing.Color]::White
$lblModel.BackColor = [System.Drawing.Color]::Transparent
$tabPlayground.Controls.Add($lblModel)

$cbModel = New-Object Windows.Forms.ComboBox
$cbModel.Location = New-Object Drawing.Point(90,150)
$cbModel.Size = New-Object Drawing.Size(320,24)
$cbModel.Items.AddRange(@('Llama-4-Maverick-17B-128E-Instruct-FP8','Llama-3-70B-Instruct','Llama-2-13B','Llama-2-7B'))
$cbModel.SelectedIndex = 0
$cbModel.BackColor = [System.Drawing.Color]::FromArgb(40,40,55)
$cbModel.ForeColor = [System.Drawing.Color]::White
$tabPlayground.Controls.Add($cbModel)


# Cmdlet label and dropdown
$lblCmdlet = New-Object Windows.Forms.Label
$lblCmdlet.Text = 'Function:'
$lblCmdlet.Location = New-Object Drawing.Point(440,150)
$lblCmdlet.Size = New-Object Drawing.Size(80,24)
$lblCmdlet.ForeColor = [System.Drawing.Color]::White
$lblCmdlet.BackColor = [System.Drawing.Color]::Transparent
$tabPlayground.Controls.Add($lblCmdlet)

$cbCmdlet = New-Object Windows.Forms.ComboBox
$cbCmdlet.Location = New-Object Drawing.Point(530,150)
$cbCmdlet.Size = New-Object Drawing.Size(240,24)
$cbCmdlet.Items.AddRange(@('Chat Completion','Moderation','List Models','DuckDuckGo Search'))
$cbCmdlet.SelectedIndex = 0
$cbCmdlet.BackColor = [System.Drawing.Color]::FromArgb(40,40,55)
$cbCmdlet.ForeColor = [System.Drawing.Color]::White
$tabPlayground.Controls.Add($cbCmdlet)


# Output label and rich text box
$lblOutput = New-Object Windows.Forms.Label
$lblOutput.Text = 'Response:'
$lblOutput.Location = New-Object Drawing.Point(20,190)
$lblOutput.Size = New-Object Drawing.Size(100,24)
$lblOutput.ForeColor = [System.Drawing.Color]::White
$lblOutput.BackColor = [System.Drawing.Color]::Transparent
$tabPlayground.Controls.Add($lblOutput)

$txtOutput = New-Object Windows.Forms.RichTextBox
$txtOutput.Location = New-Object Drawing.Point(20,220)
$txtOutput.Size = New-Object Drawing.Size(750,320)
$txtOutput.ReadOnly = $true
$txtOutput.BackColor = [System.Drawing.Color]::FromArgb(20,20,30)
$txtOutput.ForeColor = [System.Drawing.Color]::White
$txtOutput.Font = New-Object System.Drawing.Font('Consolas', 12)
$txtOutput.BorderStyle = 'FixedSingle'
$txtOutput.DetectUrls = $true
$tabPlayground.Controls.Add($txtOutput)
$null = $txtOutput.add_LinkClicked({
    param($srcSender, $e)
    $txtOutput.Clear()
    $txtOutput.SelectionColor = [System.Drawing.Color]::DeepSkyBlue
    $txtOutput.AppendText("Fetching and summarizing: " + $e.LinkText + "...\n\n")
    try {
        $web = Invoke-WebRequest -Uri $e.LinkText -UseBasicParsing -ErrorAction Stop
        $content = $web.Content
        # Simple summary: first 800 chars of visible text, or fallback to title
        $summary = $null
        if ($web.ParsedHtml -and $web.ParsedHtml.title) {
            $summary = $web.ParsedHtml.title
        }
        if ($content) {
            $plain = ($content -replace '<.*?>',' ') -replace '\s+',' '
            $plain = $plain.Trim()
            if ($plain.Length -gt 0) {
                $summary = $plain.Substring(0, [Math]::Min(800, $plain.Length)) + (if ($plain.Length -gt 800) { '...' } else { '' })
            }
        }
        if ($summary) {
            $txtOutput.SelectionColor = [System.Drawing.Color]::White
            $txtOutput.AppendText($summary)
        } else {
            $txtOutput.SelectionColor = [System.Drawing.Color]::Orange
            $txtOutput.AppendText('No summary available.')
        }
    } catch {
        $txtOutput.SelectionColor = [System.Drawing.Color]::OrangeRed
        $txtOutput.AppendText("Failed to fetch or summarize: $($_.Exception.Message)")
    }
})
# --- Tools Window Toggle ---
$toolsForm = New-Object Windows.Forms.Form
$toolsForm.Text = 'Tools Panel'
$toolsForm.Size = New-Object Drawing.Size(300,200)
$toolsForm.StartPosition = 'CenterParent'
$toolsForm.BackColor = [System.Drawing.Color]::FromArgb(40,40,55)
$toolsForm.ForeColor = [System.Drawing.Color]::White
$toolsForm.FormBorderStyle = 'FixedDialog'
$toolsForm.MaximizeBox = $false
$toolsForm.MinimizeBox = $false
$toolsForm.TopMost = $true
$toolsForm.Visible = $false


# Example: Tool use checkbox
$chkEnableTools = New-Object Windows.Forms.CheckBox
$chkEnableTools.Text = 'Enable Tool Use (web search, etc)'
$chkEnableTools.Location = New-Object Drawing.Point(20,30)
$chkEnableTools.Size = New-Object Drawing.Size(250,30)
$chkEnableTools.Checked = $true
$chkEnableTools.ForeColor = [System.Drawing.Color]::White
$toolsForm.Controls.Add($chkEnableTools)

# Run PowerShell Function tool
$lblFunc = New-Object Windows.Forms.Label
$lblFunc.Text = 'Run PowerShell Function:'
$lblFunc.Location = New-Object Drawing.Point(20,70)
$lblFunc.Size = New-Object Drawing.Size(200,22)
$lblFunc.ForeColor = [System.Drawing.Color]::DeepSkyBlue
$toolsForm.Controls.Add($lblFunc)

$cbFunc = New-Object Windows.Forms.ComboBox
$cbFunc.Location = New-Object Drawing.Point(20,95)
$cbFunc.Size = New-Object Drawing.Size(180,24)
$cbFunc.BackColor = [System.Drawing.Color]::FromArgb(40,40,55)
$cbFunc.ForeColor = [System.Drawing.Color]::White
$cbFunc.DropDownStyle = 'DropDownList'
$cbFunc.Items.AddRange((Get-Command -CommandType Function | Select-Object -ExpandProperty Name))
$toolsForm.Controls.Add($cbFunc)


$txtFuncArgs = New-Object Windows.Forms.TextBox
$txtFuncArgs.Location = New-Object Drawing.Point(210,95)
$txtFuncArgs.Size = New-Object Drawing.Size(60,24)
$txtFuncArgs.BackColor = [System.Drawing.Color]::FromArgb(40,40,55)
$txtFuncArgs.ForeColor = [System.Drawing.Color]::White
# Set PlaceholderText only if property exists (for EXE/.ps1 compatibility)
if ($txtFuncArgs.PSObject.Properties.Match('PlaceholderText').Count -gt 0) {
    $txtFuncArgs.PlaceholderText = 'Args (CSV)'
}
$toolsForm.Controls.Add($txtFuncArgs)

$btnRunFunc = New-Object Windows.Forms.Button
$btnRunFunc.Text = 'Run'
$btnRunFunc.Location = New-Object Drawing.Point(20,125)
$btnRunFunc.Size = New-Object Drawing.Size(60,28)
$btnRunFunc.BackColor = [System.Drawing.Color]::DeepSkyBlue
$btnRunFunc.ForeColor = [System.Drawing.Color]::White
$btnRunFunc.FlatStyle = 'Flat'
$btnRunFunc.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$toolsForm.Controls.Add($btnRunFunc)

$txtFuncOut = New-Object Windows.Forms.TextBox
$txtFuncOut.Location = New-Object Drawing.Point(90,125)
$txtFuncOut.Size = New-Object Drawing.Size(180,28)
$txtFuncOut.ReadOnly = $true
$txtFuncOut.BackColor = [System.Drawing.Color]::FromArgb(20,20,30)
$txtFuncOut.ForeColor = [System.Drawing.Color]::White
$toolsForm.Controls.Add($txtFuncOut)

$btnRunFunc.Add_Click({
    $func = $cbFunc.SelectedItem
    $funcArgs = $txtFuncArgs.Text
    $txtFuncOut.Text = ''
    if (-not $func) { $txtFuncOut.Text = 'No function selected.'; return }
    try {
        $argArr = if ($funcArgs) { $funcArgs -split ',' } else { @() }
        $result = & $func @argArr
        $txtFuncOut.Text = ($result | Out-String).Trim()
    } catch {
        $txtFuncOut.Text = "Error: $($_.Exception.Message)"
    }
})

# Button to open/close tools window (now on Playground tab)
$btnTools = New-Object Windows.Forms.Button
$btnTools.Text = 'Tools'
$btnTools.Location = New-Object Drawing.Point(400,560)
$btnTools.Size = New-Object Drawing.Size(80,40)
$btnTools.BackColor = [System.Drawing.Color]::FromArgb(60,60,80)
$btnTools.ForeColor = [System.Drawing.Color]::White
$btnTools.FlatStyle = 'Flat'
$btnTools.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$tabPlayground.Controls.Add($btnTools)

$btnTools.Add_Click({
    $toolsForm.Visible = -not $toolsForm.Visible
    if ($toolsForm.Visible) { $toolsForm.Activate() }
})


# Send button
$btnSend = New-Object Windows.Forms.Button
$btnSend.Text = 'Send'
$btnSend.Location = New-Object Drawing.Point(350,560)
$btnSend.Size = New-Object Drawing.Size(120,40)
$btnSend.BackColor = [System.Drawing.Color]::DeepSkyBlue
$btnSend.ForeColor = [System.Drawing.Color]::White
$btnSend.FlatStyle = 'Flat'
$btnSend.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
$tabPlayground.Controls.Add($btnSend)

$btnSend.Add_Click({
    $prompt = $txtPrompt.Text
    $systemMsg = $txtSystem.Text
    $model = $cbModel.SelectedItem
    $cmdlet = $cbCmdlet.SelectedItem
    $txtOutput.Clear()
    if (-not $prompt -and $cmdlet -eq 'Chat Completion') {
        [System.Windows.Forms.MessageBox]::Show('Please enter a prompt.','Input Required',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    $messages = @()
    if ($systemMsg -and $systemMsg -ne 'You are a helpful assistant.') {
        $messages += @{ role = 'system'; content = $systemMsg }
    }
    if ($prompt) {
        $messages += @{ role = 'user'; content = $prompt }
    }
    try {
        $toolUseEnabled = $true
        if ($chkEnableTools -ne $null) { $toolUseEnabled = $chkEnableTools.Checked }
        if ($cmdlet -eq 'DuckDuckGo Search' -and -not $toolUseEnabled) {
            $txtOutput.SelectionColor = [System.Drawing.Color]::Orange
            $txtOutput.AppendText('Tool use is disabled. Enable it in the Tools panel to use web search.')
            return
        }
        if ($cmdlet -eq 'Chat Completion') {
            $response = Invoke-LlamaApiRequest -Messages $messages -Model $model
            if ($response -and $response.choices -and $response.choices[0] -and $response.choices[0].message.content) {
                $txtOutput.SelectionColor = [System.Drawing.Color]::White
                $txtOutput.AppendText($response.choices[0].message.content)
                Add-ToHistory -Request $messages -Response $response
            } else {
                $txtOutput.SelectionColor = [System.Drawing.Color]::Orange
                $txtOutput.AppendText(($response | ConvertTo-Json -Depth 10))
            }
        } elseif ($cmdlet -eq 'Moderation') {
            $modPrompt = "Please analyze the following text for safety issues, harmful content, bias, or inappropriate material. Provide a detailed assessment and safety score (1-10). Text: $prompt"
            $modMessages = @(@{ role = 'user'; content = $modPrompt })
            $response = Invoke-LlamaApiRequest -Messages $modMessages -Model $model
            if ($response -and $response.choices -and $response.choices[0] -and $response.choices[0].message.content) {
                $txtOutput.SelectionColor = [System.Drawing.Color]::White
                $txtOutput.AppendText($response.choices[0].message.content)
                Add-ToHistory -Request $modMessages -Response $response
            } else {
                $txtOutput.SelectionColor = [System.Drawing.Color]::Orange
                $txtOutput.AppendText(($response | ConvertTo-Json -Depth 10))
            }
        } elseif ($cmdlet -eq 'List Models') {
            $listPrompt = 'List all available models and their main features.'
            $listMessages = @(@{ role = 'user'; content = $listPrompt })
            $response = Invoke-LlamaApiRequest -Messages $listMessages -Model $model
            if ($response -and $response.choices -and $response.choices[0] -and $response.choices[0].message.content) {
                $txtOutput.SelectionColor = [System.Drawing.Color]::White
                $txtOutput.AppendText($response.choices[0].message.content)
                Add-ToHistory -Request $listMessages -Response $response
            } else {
                $txtOutput.SelectionColor = [System.Drawing.Color]::Orange
                $txtOutput.AppendText(($response | ConvertTo-Json -Depth 10))
            }
        } elseif ($cmdlet -eq 'DuckDuckGo Search') {
            if (-not $prompt) {
                [System.Windows.Forms.MessageBox]::Show('Please enter a search query.','Input Required',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
                return
            }
            $searchMode = $cbSearchMode.SelectedItem
            $results = Invoke-DuckDuckGoSearch -Query $prompt -Count 5
            if ($searchMode -eq 'View Links') {
                if ($results -and $results.Count -gt 0) {
                    foreach ($result in $results) {
                        $txtOutput.SelectionColor = [System.Drawing.Color]::DeepSkyBlue
                        $txtOutput.SelectionFont = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold)
                        $txtOutput.AppendText("• " + $result.Title + "\n")
                        $txtOutput.SelectionColor = [System.Drawing.Color]::LightGreen
                        $txtOutput.SelectionFont = New-Object System.Drawing.Font('Consolas', 11, [System.Drawing.FontStyle]::Underline)
                        $txtOutput.AppendText($result.Url + "\n\n")
                    }
                } else {
                    $txtOutput.SelectionColor = [System.Drawing.Color]::Orange
                    $txtOutput.AppendText('No results found.')
                }
            } elseif ($searchMode -eq 'Smart Answer') {
                if ($results -and $results.Count -gt 0) {
                    $txtOutput.SelectionColor = [System.Drawing.Color]::DeepSkyBlue
                    $txtOutput.AppendText('Fetching and analyzing top results...\n\n')
                    $sources = @()
                    $texts = @()
                    $i = 1
                    foreach ($result in $results[0..2]) {
                        # DuckDuckGo result URLs may be redirect links, decode uddg param if present
                        $url = $result.Url
                        if ($url -match 'uddg=([^&]+)') {
                            $url = [System.Uri]::UnescapeDataString(($url -replace '.*uddg=([^&]+).*','$1'))
                        }
                        $sources += $url
                        try {
                            $web = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
                            $content = $web.Content
                            $plain = ($content -replace '<.*?>',' ') -replace '\s+',' '
                            $plain = $plain.Trim()
                            $texts += "Source [$i]: $plain"
                        } catch {
                            $texts += "Source [$i]: (Failed to fetch or parse)"
                        }
                        $i++
                    }
                    # Compose prompt for Llama API
                    $context = ($texts -join '\n\n')
                    $llamaPrompt = "Given the following web search results, answer the user's question and cite sources as [1], [2], etc.\n\nUser's question: $prompt\n\nWeb results:\n$context"
                    $llamaMessages = @(@{ role = 'user'; content = $llamaPrompt })
                    $response = Invoke-LlamaApiRequest -Messages $llamaMessages -Model $model
                    if ($response -and $response.choices -and $response.choices[0] -and $response.choices[0].message.content) {
                        $txtOutput.SelectionColor = [System.Drawing.Color]::White
                        $txtOutput.AppendText($response.choices[0].message.content + "\n\n")
                        $txtOutput.SelectionColor = [System.Drawing.Color]::DeepSkyBlue
                        $txtOutput.AppendText('Sources:\n')
                        $j = 1
                        foreach ($src in $sources) {
                            $txtOutput.SelectionColor = [System.Drawing.Color]::LightGreen
                            $txtOutput.AppendText("[$j] $src\n")
                            $j++
                        }
                    } else {
                        $txtOutput.SelectionColor = [System.Drawing.Color]::Orange
                        $txtOutput.AppendText('No answer generated.')
                    }
                } else {
                    $txtOutput.SelectionColor = [System.Drawing.Color]::Orange
                    $txtOutput.AppendText('No results found.')
                }
            }
        }
    } catch {
        $txtOutput.Text = "Error: $($_.Exception.Message)"
    }
})


# Error label
$lblError = New-Object Windows.Forms.Label
$lblError.Text = ''
$lblError.ForeColor = [System.Drawing.Color]::OrangeRed
$lblError.BackColor = [System.Drawing.Color]::Transparent
$lblError.Location = New-Object Drawing.Point(20,560)
$lblError.Size = New-Object Drawing.Size(320,30)
$lblError.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Italic)
$tabPlayground.Controls.Add($lblError)


# Clear button
$btnClear = New-Object Windows.Forms.Button
$btnClear.Text = 'Clear'
$btnClear.Location = New-Object Drawing.Point(500,560)
$btnClear.Size = New-Object Drawing.Size(80,40)
$btnClear.BackColor = [System.Drawing.Color]::FromArgb(60,60,80)
$btnClear.ForeColor = [System.Drawing.Color]::White
$btnClear.FlatStyle = 'Flat'
$btnClear.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$tabPlayground.Controls.Add($btnClear)

# History button
$btnHistory = New-Object Windows.Forms.Button
$btnHistory.Text = 'History'
$btnHistory.Location = New-Object Drawing.Point(600,560)
$btnHistory.Size = New-Object Drawing.Size(80,40)
$btnHistory.BackColor = [System.Drawing.Color]::FromArgb(60,60,80)
$btnHistory.ForeColor = [System.Drawing.Color]::White
$btnHistory.FlatStyle = 'Flat'
$btnHistory.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$tabPlayground.Controls.Add($btnHistory)

# Export button
$btnExport = New-Object Windows.Forms.Button
$btnExport.Text = 'Export'
$btnExport.Location = New-Object Drawing.Point(700,560)
$btnExport.Size = New-Object Drawing.Size(80,40)
$btnExport.BackColor = [System.Drawing.Color]::FromArgb(60,60,80)
$btnExport.ForeColor = [System.Drawing.Color]::White
$btnExport.FlatStyle = 'Flat'
$btnExport.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$tabPlayground.Controls.Add($btnExport)

$btnClear.Add_Click({
    $txtPrompt.Text = ''
    $txtSystem.Text = 'You are a helpful assistant.'
    $txtOutput.Text = ''
    $lblError.Text = ''
})

$btnHistory.Add_Click({
    try {
        $historyPath = "$PSScriptRoot\..\history.json"
        if (Test-Path $historyPath) {
            $history = Get-Content $historyPath | ConvertFrom-Json
            $historyView = @()
            for ($i = 0; $i -lt $history.Count; $i++) {
                $entry = $history[$i]
                $requestSummary = if ($entry.Request -is [array] -and $entry.Request[0].content) {
                    $entry.Request[0].content.Substring(0, [Math]::Min(100, $entry.Request[0].content.Length)) + "..."
                } else {
                    "Request data"
                }
                $responseSummary = if ($entry.Response.choices -and $entry.Response.choices[0].message.content) {
                    $entry.Response.choices[0].message.content.Substring(0, [Math]::Min(100, $entry.Response.choices[0].message.content.Length)) + "..."
                } else {
                    "Response data"
                }
                $tokens = if ($entry.Response.metrics) {
                    ($entry.Response.metrics | Where-Object metric -eq 'num_total_tokens' | Select-Object -ExpandProperty value)
                } else { "N/A" }
                $historyView += [PSCustomObject]@{
                    Index = $i + 1
                    Timestamp = $entry.Timestamp
                    RequestPreview = $requestSummary
                    ResponsePreview = $responseSummary
                    Tokens = $tokens
                }
            }
            $selected = $historyView | Out-GridView -Title 'Llama API Playground - History' -PassThru
            if ($selected) {
                $txtPrompt.Text = $selected.RequestPreview
                $txtOutput.Text = $selected.ResponsePreview
            }
        } else {
            $lblError.Text = 'No history file found.'
        }
    } catch {
        $lblError.Text = "Error reading history: $($_.Exception.Message)"
    }
})

$btnExport.Add_Click({
    try {
        $output = $txtOutput.Text
        if (-not $output) {
            $lblError.Text = 'Nothing to export.'
            return
        }
        $saveDialog = New-Object Windows.Forms.SaveFileDialog
        $saveDialog.Filter = 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*'
        $saveDialog.Title = 'Export Playground Output'
        if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            Set-Content -Path $saveDialog.FileName -Value $output
            $lblError.Text = 'Exported successfully.'
        }
    } catch {
        $lblError.Text = "Export failed: $($_.Exception.Message)"
    }
})

$form.ShowDialog()

# SIG # Begin signature block
# MIIb+QYJKoZIhvcNAQcCoIIb6jCCG+YCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB96/NQosyTIvcp
# Nj7Us+GN2Ub5XqGjQ5h8faOdFlNNraCCFkQwggMGMIIB7qADAgECAhBJrX+vaf9M
# m0SKuNP0UT3JMA0GCSqGSIb3DQEBCwUAMBsxGTAXBgNVBAMMEFNjcmVlbkhlbHBT
# aWduZXIwHhcNMjUwNjE1MDUwMjQ2WhcNMjYwNjE1MDUyMjQ2WjAbMRkwFwYDVQQD
# DBBTY3JlZW5IZWxwU2lnbmVyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEA3JYeZNTeFXugPn5QCp6BT4A8pfru7ppVUXlrNSPcqfKDmGLVjtxLc45+zV/M
# 34dJvD2ZboZwojR8O5gwb7k7Seg0+KP4zGCZe39VNOer2SZujaP59IZb+/5/HOBN
# qz61RO1hnXiOUGexnO35j8ZshL48AkCItWvUI5JW65KezSUkFHCce7YoJIft0qAm
# G+PKn3L7lc9y5rHqY55cFZyY0063YAe9RFn/8tuwDSU7ti8TD2HOAK4sPBRhR7HC
# x7CQH6sJw4TE0q59ng5dA454sG0D+4vji3KvHhOgruv2+yEyGpCSm7v7ybq76RJ6
# M2kgVLyqGjKq1+XDbwa6DxXQLQIDAQABo0YwRDAOBgNVHQ8BAf8EBAMCB4AwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFHUg4GzlfXVfKriv5rSJlEVORIyu
# MA0GCSqGSIb3DQEBCwUAA4IBAQAbI8omFLPJfwRk9jtFvDJCopOQHWze3iBqRh8O
# yu7knu0AbKaoGCr9QR+pQHdejhxkbQE+T8cl3uF19M6BCH83zJzGDjQUVx5F9kms
# 6Ee8gx0g4daDEAm3hjS4uQ62MCeiapMMt5hiNHJhR0BoR+ExMFwdhIJCjlG9yYLo
# Z6Vpu0tXRv2AkPFPzhwipQcrUAT+8IhxSqYnAv53Jc0eDw0bBUX6K7y4Wr8DXfeJ
# ym84WWEHw77kzV7808ZwLliKRdjdVv49gz8GqZpjYU0DiLNVr/tYWd/oV+e4adVu
# hyIEV8RKyHgMw6fA1140HycbGt5YvBWfFbqMEe9S+T/2ZCfcMIIFjTCCBHWgAwIB
# AgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0BAQwFADBlMQswCQYDVQQGEwJV
# UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
# Y29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMjIw
# ODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UE
# ChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYD
# VQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz7MKnJS7JIT3yithZwuEppz1Y
# q3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS5F/WBTxSD1Ifxp4VpX6+n6lX
# FllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7bXHiLQwb7iDVySAdYyktzuxe
# TsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfISKhmV1efVFiODCu3T6cw2Vbu
# yntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jHtrHEtWoYOAMQjdjUN6QuBX2I
# 9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14Ztk6MUSaM0C/CNdaSaTC5qmg
# Z92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2h4mXaXpI8OCiEhtmmnTK3kse
# 5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt6zPZxd9LBADMfRyVw4/3IbKy
# Ebe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPRiQfhvbfmQ6QYuKZ3AeEPlAwh
# HbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ERElvlEFDrMcXKchYiCd98THU/
# Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4KJpn15GkvmB0t9dmpsh3lGwID
# AQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU7NfjgtJxXWRM
# 3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDgYD
# VR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDov
# L29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MEUGA1UdHwQ+
# MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3Vy
# ZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRVHSAAMA0GCSqGSIb3DQEBDAUA
# A4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyhhyzshV6pGrsi+IcaaVQi7aSI
# d229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO0Cre+i1Wz/n096wwepqLsl7U
# z9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo8L8vC6bp8jQ87PcDx4eo0kxA
# GTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++hUD38dglohJ9vytsgjTVgHAID
# yyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5xaiNrIv8SuFQtJ37YOtnwtoeW
# /VvRXKwYw02fc7cBqZ9Xql4o4rmUMIIGtDCCBJygAwIBAgIQDcesVwX/IZkuQEMi
# DDpJhjANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
# aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhE
# aWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjUwNTA3MDAwMDAwWhcNMzgwMTE0
# MjM1OTU5WjBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4x
# QTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1waW5nIFJTQTQw
# OTYgU0hBMjU2IDIwMjUgQ0ExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKC
# AgEAtHgx0wqYQXK+PEbAHKx126NGaHS0URedTa2NDZS1mZaDLFTtQ2oRjzUXMmxC
# qvkbsDpz4aH+qbxeLho8I6jY3xL1IusLopuW2qftJYJaDNs1+JH7Z+QdSKWM06qc
# hUP+AbdJgMQB3h2DZ0Mal5kYp77jYMVQXSZH++0trj6Ao+xh/AS7sQRuQL37QXbD
# hAktVJMQbzIBHYJBYgzWIjk8eDrYhXDEpKk7RdoX0M980EpLtlrNyHw0Xm+nt5pn
# YJU3Gmq6bNMI1I7Gb5IBZK4ivbVCiZv7PNBYqHEpNVWC2ZQ8BbfnFRQVESYOszFI
# 2Wv82wnJRfN20VRS3hpLgIR4hjzL0hpoYGk81coWJ+KdPvMvaB0WkE/2qHxJ0ucS
# 638ZxqU14lDnki7CcoKCz6eum5A19WZQHkqUJfdkDjHkccpL6uoG8pbF0LJAQQZx
# st7VvwDDjAmSFTUms+wV/FbWBqi7fTJnjq3hj0XbQcd8hjj/q8d6ylgxCZSKi17y
# Vp2NL+cnT6Toy+rN+nM8M7LnLqCrO2JP3oW//1sfuZDKiDEb1AQ8es9Xr/u6bDTn
# YCTKIsDq1BtmXUqEG1NqzJKS4kOmxkYp2WyODi7vQTCBZtVFJfVZ3j7OgWmnhFr4
# yUozZtqgPrHRVHhGNKlYzyjlroPxul+bgIspzOwbtmsgY1MCAwEAAaOCAV0wggFZ
# MBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFO9vU0rp5AZ8esrikFb2L9RJ
# 7MtOMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1UdDwEB/wQE
# AwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkwJAYIKwYB
# BQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0
# cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5j
# cnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJ
# YIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQAXzvsWgBz+Bz0RdnEwvb4LyLU0
# pn/N0IfFiBowf0/Dm1wGc/Do7oVMY2mhXZXjDNJQa8j00DNqhCT3t+s8G0iP5kvN
# 2n7Jd2E4/iEIUBO41P5F448rSYJ59Ib61eoalhnd6ywFLerycvZTAz40y8S4F3/a
# +Z1jEMK/DMm/axFSgoR8n6c3nuZB9BfBwAQYK9FHaoq2e26MHvVY9gCDA/JYsq7p
# GdogP8HRtrYfctSLANEBfHU16r3J05qX3kId+ZOczgj5kjatVB+NdADVZKON/gnZ
# ruMvNYY2o1f4MXRJDMdTSlOLh0HCn2cQLwQCqjFbqrXuvTPSegOOzr4EWj7PtspI
# HBldNE2K9i697cvaiIo2p61Ed2p8xMJb82Yosn0z4y25xUbI7GIN/TpVfHIqQ6Ku
# /qjTY6hc3hsXMrS+U0yy+GWqAXam4ToWd2UQ1KYT70kZjE4YtL8Pbzg0c1ugMZyZ
# Zd/BdHLiRu7hAWE6bTEm4XYRkA6Tl4KSFLFk43esaUeqGkH/wyW4N7OigizwJWeu
# kcyIPbAvjSabnf7+Pu0VrFgoiovRDiyx3zEdmcif/sYQsfch28bZeUz2rtY/9TCA
# 6TD8dC3JE3rYkrhLULy7Dc90G6e8BlqmyIjlgp2+VqsS9/wQD7yFylIz0scmbKvF
# oW2jNrbM1pD2T7m3XDCCBu0wggTVoAMCAQICEAqA7xhLjfEFgtHEdqeVdGgwDQYJ
# KoZIhvcNAQELBQAwaTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJ
# bmMuMUEwPwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVTdGFtcGluZyBS
# U0E0MDk2IFNIQTI1NiAyMDI1IENBMTAeFw0yNTA2MDQwMDAwMDBaFw0zNjA5MDMy
# MzU5NTlaMGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7
# MDkGA1UEAxMyRGlnaUNlcnQgU0hBMjU2IFJTQTQwOTYgVGltZXN0YW1wIFJlc3Bv
# bmRlciAyMDI1IDEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDQRqwt
# Esae0OquYFazK1e6b1H/hnAKAd/KN8wZQjBjMqiZ3xTWcfsLwOvRxUwXcGx8AUjn
# i6bz52fGTfr6PHRNv6T7zsf1Y/E3IU8kgNkeECqVQ+3bzWYesFtkepErvUSbf+EI
# YLkrLKd6qJnuzK8Vcn0DvbDMemQFoxQ2Dsw4vEjoT1FpS54dNApZfKY61HAldytx
# NM89PZXUP/5wWWURK+IfxiOg8W9lKMqzdIo7VA1R0V3Zp3DjjANwqAf4lEkTlCDQ
# 0/fKJLKLkzGBTpx6EYevvOi7XOc4zyh1uSqgr6UnbksIcFJqLbkIXIPbcNmA98Os
# kkkrvt6lPAw/p4oDSRZreiwB7x9ykrjS6GS3NR39iTTFS+ENTqW8m6THuOmHHjQN
# C3zbJ6nJ6SXiLSvw4Smz8U07hqF+8CTXaETkVWz0dVVZw7knh1WZXOLHgDvundrA
# tuvz0D3T+dYaNcwafsVCGZKUhQPL1naFKBy1p6llN3QgshRta6Eq4B40h5avMcpi
# 54wm0i2ePZD5pPIssoszQyF4//3DoK2O65Uck5Wggn8O2klETsJ7u8xEehGifgJY
# i+6I03UuT1j7FnrqVrOzaQoVJOeeStPeldYRNMmSF3voIgMFtNGh86w3ISHNm0Ia
# adCKCkUe2LnwJKa8TIlwCUNVwppwn4D3/Pt5pwIDAQABo4IBlTCCAZEwDAYDVR0T
# AQH/BAIwADAdBgNVHQ4EFgQU5Dv88jHt/f3X85FxYxlQQ89hjOgwHwYDVR0jBBgw
# FoAU729TSunkBnx6yuKQVvYv1Ensy04wDgYDVR0PAQH/BAQDAgeAMBYGA1UdJQEB
# /wQMMAoGCCsGAQUFBwMIMIGVBggrBgEFBQcBAQSBiDCBhTAkBggrBgEFBQcwAYYY
# aHR0cDovL29jc3AuZGlnaWNlcnQuY29tMF0GCCsGAQUFBzAChlFodHRwOi8vY2Fj
# ZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRUaW1lU3RhbXBpbmdS
# U0E0MDk2U0hBMjU2MjAyNUNBMS5jcnQwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDov
# L2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0VGltZVN0YW1waW5n
# UlNBNDA5NlNIQTI1NjIwMjVDQTEuY3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsG
# CWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAZSqt8RwnBLmuYEHs0QhEnmNA
# ciH45PYiT9s1i6UKtW+FERp8FgXRGQ/YAavXzWjZhY+hIfP2JkQ38U+wtJPBVBaj
# YfrbIYG+Dui4I4PCvHpQuPqFgqp1PzC/ZRX4pvP/ciZmUnthfAEP1HShTrY+2DE5
# qjzvZs7JIIgt0GCFD9ktx0LxxtRQ7vllKluHWiKk6FxRPyUPxAAYH2Vy1lNM4kze
# kd8oEARzFAWgeW3az2xejEWLNN4eKGxDJ8WDl/FQUSntbjZ80FU3i54tpx5F/0Kr
# 15zW/mJAxZMVBrTE2oi0fcI8VMbtoRAmaaslNXdCG1+lqvP4FbrQ6IwSBXkZagHL
# hFU9HCrG/syTRLLhAezu/3Lr00GrJzPQFnCEH1Y58678IgmfORBPC1JKkYaEt2Od
# Dh4GmO0/5cHelAK2/gTlQJINqDr6JfwyYHXSd+V08X1JUPvB4ILfJdmL+66Gp3CS
# BXG6IwXMZUXBhtCyIaehr0XkBoDIGMUG1dUtwq1qmcwbdUfcSYCn+OwncVUXf53V
# JUNOaMWMts0VlRYxe5nK+At+DI96HAlXHAL5SlfYxJ7La54i71McVWRP66bW+yER
# NpbJCjyCYG2j+bdpxo/1Cy4uPcU3AWVPGrbn5PhDBf3Froguzzhk++ami+r3Qrx5
# bIbY3TVzgiFI7Gq3zWcxggULMIIFBwIBATAvMBsxGTAXBgNVBAMMEFNjcmVlbkhl
# bHBTaWduZXICEEmtf69p/0ybRIq40/RRPckwDQYJYIZIAWUDBAIBBQCggYQwGAYK
# KwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# UT+Qp4Z1CMZUnhoaITvD1EUCbLIOHpeDVrifE8tYw1IwDQYJKoZIhvcNAQEBBQAE
# ggEArWXvssSYPxsqWUDmEiZ4xRJke/4hidjjUqqAVaxRURyKNjjtQtJ8g3DPM8OI
# r8AlC3YThlei2p3UtIn85kjRoDiAAe9rmMC+6w8JdSzsrRinkZv6KvtieZW38I8W
# L17F2yknjQg0OHYD3HRiO6WtN1d0ERoKW4qJ+C0FkiclqvZRetrGiqx1pXyVDFr9
# 7yWHw6Nh10UkD7JGYs2VqQPDyD8DcRHjpuK+2rYC9sVJqnyH2dK72+S3YFRAoOHw
# QROV2OktRyS+o/4YCSCaCooPVNTDuroSPqIkOxTPBlYgAfdzy4H9Ic7yv91D+Tdl
# beUCJ0uKLW3F69KDpB1cxKfk2KGCAyYwggMiBgkqhkiG9w0BCQYxggMTMIIDDwIB
# ATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8G
# A1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBT
# SEEyNTYgMjAyNSBDQTECEAqA7xhLjfEFgtHEdqeVdGgwDQYJYIZIAWUDBAIBBQCg
# aTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yNTA4
# MDIxNzA4NDRaMC8GCSqGSIb3DQEJBDEiBCA869Rh+2nxU+yi9Lp8UaZlXFcF2gp1
# MA8aCt1Iez4gvjANBgkqhkiG9w0BAQEFAASCAgB+s5dmUr7XGl1zprChuSt8r5WQ
# CauHIJDHEMRt+xIvZ16tDw0+POR+eIG3MLdQKTvINAU+Pv8QA1FtRbHrbWUvobvE
# 8rVx3h/4FO4py1s6ogwzUUkFwRp7AAmqBj07bD6HVlsLOycZX7yon8GILhfpoAKP
# 6axL2ZhdyM1rcJK9MlXMQR/oqG1sFSOQl3EL/weOyUlbGoQeivqHvJqom6xbbSOv
# +n7gxViKGizuvbmajL0sf9nHE602g2OUvIEdITSOfjt/pE/evgjo9yjqbUhfoRUw
# nH7ZJsR3ux03plVETZyVn524CYnbN+OOswlyiE2GwRq4UEaQ71izNOeIZzIO4XHP
# wjPVUBqe1mRP3enaU9VnwbodJIbySNbgIz+09G3E4zAR9BQ69i2u8DFm+b4UJQJA
# q8ZqvIfU7KcyotAWC0G9AK9wQZfXriL9QhiOMaXR6VNO2B9b6WfZFX3joHA0eDeu
# XCXRmrVdsKZMhMY2tPhJ8WYFgNnKe7L28FE5c6Gd4Ozsy02yc3hCPFiJuLoLPgza
# 5EjuGZG/I8hRNkWY36s8f6hjpIFSSiDQZOdUh/oxDsH5/g1zOBy1JENHLSFPO11w
# Fg6zW6t/A6jfz6MJ2a3hQuxjuFaK2pvv05lWr/4yIripbeJaoqKQUfKxaR5YGWdY
# b1xxqM5wS3lCwIn/DQ==
# SIG # End signature block
