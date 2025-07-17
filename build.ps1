# Build and Development Helper Script
# This script helps with common development tasks

param(
    [ValidateSet('Build', 'Test', 'Clean', 'Install', 'Publish', 'Help')]
    [string]$Task = 'Help'
)

$ModulePath = Join-Path $PSScriptRoot "CalendarSync"
$ModuleName = "CalendarSync"

switch ($Task)
{
    'Build'
    {
        Write-Host "Building module..." -ForegroundColor Green
        
        # Test module manifest
        $manifestPath = Join-Path $ModulePath "$ModuleName.psd1"
        if (Test-ModuleManifest $manifestPath)
        {
            Write-Host "✅ Module manifest is valid" -ForegroundColor Green
        }
        else
        {
            Write-Host "❌ Module manifest validation failed" -ForegroundColor Red
            exit 1
        }
        
        # Check for syntax errors
        $ErrorCount = 0
        Get-ChildItem -Path $ModulePath -Recurse -Filter "*.ps1" | ForEach-Object {
            $Content = Get-Content $_.FullName -Raw
            $Tokens = $null
            $ParseErrors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($Content, [ref]$Tokens, [ref]$ParseErrors)
            if ($ParseErrors)
            {
                Write-Host "❌ Parse errors in $($_.FullName):" -ForegroundColor Red
                $ParseErrors | ForEach-Object { Write-Host "  $($_.Message)" -ForegroundColor Red }
                $ErrorCount++
            }
        }
        
        if ($ErrorCount -eq 0)
        {
            Write-Host "✅ No syntax errors found" -ForegroundColor Green
        }
        else
        {
            Write-Host "❌ Found $ErrorCount files with syntax errors" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "✅ Build completed successfully" -ForegroundColor Green
    }
    
    'Test'
    {
        Write-Host "Testing module..." -ForegroundColor Green
        
        # Remove any existing module and import fresh
        Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue
        Import-Module $ModulePath -Force
        
        # Test basic functionality
        $Commands = Get-Command -Module $ModuleName
        Write-Host "✅ Module imported successfully with $($Commands.Count) commands:" -ForegroundColor Green
        $Commands | ForEach-Object { Write-Host "  - $($_.Name)" }
        
        # Test help system
        Write-Host "`nTesting help system..." -ForegroundColor Yellow
        try
        {
            Get-Help Sync-CalendarEvents -Examples | Out-Null
            Write-Host "✅ Help system working" -ForegroundColor Green
        }
        catch
        {
            Write-Host "❌ Help system issues: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host "✅ Basic tests completed" -ForegroundColor Green
    }
    
    'Clean'
    {
        Write-Host "Cleaning up..." -ForegroundColor Green
        
        # Remove result files
        Get-ChildItem -Path $PSScriptRoot -Filter "calendarSync_results_*.json" | Remove-Item -Force
        
        # Remove module from session
        Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue
        
        Write-Host "✅ Cleanup completed" -ForegroundColor Green
    }
    
    'Install'
    {
        Write-Host "Installing required dependencies..." -ForegroundColor Green
        
        $RequiredModules = @(
            'Microsoft.Graph',
            'PSFramework'
        )
        
        foreach ($Module in $RequiredModules)
        {
            if (-not (Get-Module $Module -ListAvailable))
            {
                Write-Host "Installing $Module..." -ForegroundColor Yellow
                Install-Module $Module -Force -Scope CurrentUser
            }
            else
            {
                Write-Host "✅ $Module is already installed" -ForegroundColor Green
            }
        }
        
        Write-Host "✅ Dependencies installed" -ForegroundColor Green
    }
    
    'Publish'
    {
        Write-Host "Preparing for publication..." -ForegroundColor Green
        
        # Run build first
        & $PSCommandPath -Task Build
        
        # Update version if needed
        $manifest = Import-PowerShellDataFile (Join-Path $ModulePath "$ModuleName.psd1")
        Write-Host "Current version: $($manifest.ModuleVersion)" -ForegroundColor Yellow
        
        # Check if all required files exist
        $RequiredFiles = @(
            'README.md',
            'LICENSE',
            'CHANGELOG.md'
        )
        
        $Missing = @()
        foreach ($File in $RequiredFiles)
        {
            if (-not (Test-Path (Join-Path $PSScriptRoot $File)))
            {
                $Missing += $File
            }
        }
        
        if ($Missing.Count -gt 0)
        {
            Write-Host "❌ Missing required files: $($Missing -join ', ')" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "✅ Ready for publication" -ForegroundColor Green
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  1. Commit and push changes to GitHub" -ForegroundColor Yellow
        Write-Host "  2. Create a release tag" -ForegroundColor Yellow
        Write-Host "  3. Publish to PowerShell Gallery if desired" -ForegroundColor Yellow
    }
    
    'Help'
    {
        Write-Host "CalendarSync Development Helper" -ForegroundColor Green
        Write-Host "Usage: .\build.ps1 -Task <TaskName>" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Available tasks:" -ForegroundColor Cyan
        Write-Host "  Build    - Validate module manifest and check syntax"
        Write-Host "  Test     - Import module and run basic tests"
        Write-Host "  Clean    - Remove temporary files and unload module"
        Write-Host "  Install  - Install required dependencies"
        Write-Host "  Publish  - Prepare module for publication"
        Write-Host "  Help     - Show this help message"
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Cyan
        Write-Host "  .\build.ps1 -Task Build"
        Write-Host "  .\build.ps1 -Task Test"
        Write-Host "  .\build.ps1 -Task Install"
    }
}
