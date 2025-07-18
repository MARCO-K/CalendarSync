#requires -Version 5.1
#requires -Module PSFramework

# CalendarSync PowerShell Module v1.0
# Synchronizes calendar events between Microsoft Graph API and SharePoint lists

# Get module and project root paths
$ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ModuleRoot

# Load default configuration from project root (before functions that might need it)
$DefaultConfigPath = Join-Path $ProjectRoot "DefaultConfig.ps1"
if (Test-Path $DefaultConfigPath)
{
    try
    {
        . $DefaultConfigPath
        Write-Verbose "Loaded default configuration from: $DefaultConfigPath"
    }
    catch
    {
        Write-Error "Failed to load default configuration: $($_.Exception.Message)"
    }
}
else
{
    Write-Warning "DefaultConfig.ps1 not found at: $DefaultConfigPath"
}

# Import internal functions (helper functions)
$InternalFunctions = Get-ChildItem -Path "$ModuleRoot\internal\*.ps1" -ErrorAction SilentlyContinue
foreach ($Function in $InternalFunctions)
{
    try
    {
        . $Function.FullName
        Write-Verbose "Loaded internal function: $($Function.BaseName)"
    }
    catch
    {
        Write-Error "Failed to load internal function $($Function.BaseName): $($_.Exception.Message)"
    }
}

# Import public functions (main functions)
$PublicFunctions = Get-ChildItem -Path "$ModuleRoot\functions\*.ps1" -ErrorAction SilentlyContinue
foreach ($Function in $PublicFunctions)
{
    try
    {
        . $Function.FullName
        Write-Verbose "Loaded public function: $($Function.BaseName)"
    }
    catch
    {
        Write-Error "Failed to load public function $($Function.BaseName): $($_.Exception.Message)"
    }
}

# Initialize PSFramework if not already loaded
if (-not (Get-Module PSFramework -ListAvailable))
{
    Write-Warning "PSFramework module not found. Installing..."
    Install-Module PSFramework -Force -Scope CurrentUser
}
Import-Module PSFramework

# Export only public functions
Export-ModuleMember -Function @(
    'Sync-CalendarEvent',
    'Connect-ToMicrosoftGraph',
    'Get-SharePointListItems',
    'ConvertTo-FormattedEvent',
    'Export-ResultsToJson',
    'Get-Configuration'
)

