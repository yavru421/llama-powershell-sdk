@{
    # Script module or binary module file associated with this manifest
    RootModule = 'LlamaApi.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b1a1c1e0-0000-4000-9000-000000000001'
    Author = 'Your Name'
    CompanyName = 'Your Company'
    Copyright = '(c) 2025 Your Name. All rights reserved.'
    Description = 'A PowerShell SDK for interacting with the Llama API.'
    FunctionsToExport = @('Invoke-LlamaApiRequest','Get-LlamaApiResource','Invoke-LlamaChat')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{ Tags = @('Llama','AI','SDK','Chat','PowerShell'); LicenseUri = 'https://opensource.org/licenses/MIT'; ProjectUri = 'https://github.com/yourname/llama-api-powershell' }
}
