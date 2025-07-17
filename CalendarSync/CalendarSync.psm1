# CalendarSync PowerShell Module
# Synchronizes calendar events between Microsoft Graph API and SharePoint lists

# Get module root path
$ModuleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

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
    'Sync-CalendarEvents',
    'Connect-ToMicrosoftGraph',
    'Get-SharePointListItems',
    'ConvertTo-FormattedEvents',
    'Export-ResultsToJson'
)
