# Basic tests for Llama API Playground

Describe 'Llama API Playground' {
    It 'Should import main Playground script' {
        . $PSScriptRoot\..\src\Playground.ps1
        $true | Should -Be $true
    }
}
