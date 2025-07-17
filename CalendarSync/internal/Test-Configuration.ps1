function Test-Configuration
{
    <#
    .SYNOPSIS
        Validates configuration for the Calendar Sync module
    .DESCRIPTION
        Checks that all required configuration properties are present and valid
    .PARAMETER Config
        Configuration object to validate
    .EXAMPLE
        Test-Configuration -Config $config
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Config
    )
    
    $isValid = $true
    
    # Check required SharePoint properties
    if (-not $Config.SharePoint -or -not $Config.SharePoint.ListID -or -not $Config.SharePoint.SiteID)
    {
        Write-PSFMessage -Level Error -Message "Invalid configuration: SharePoint.ListID and SharePoint.SiteID are required"
        $isValid = $false
    }
    
    # Check required FieldMappings
    $requiredFields = @('Title', 'Description', 'StartDate', 'EndDate', 'Location')
    foreach ($field in $requiredFields)
    {
        if (-not $Config.FieldMappings.$field)
        {
            Write-PSFMessage -Level Error -Message "Invalid configuration: FieldMappings.$field is required"
            $isValid = $false
        }
    }
    
    # Check DateRange values
    if ($Config.DateRange.FutureDays -lt 1 -or $Config.DateRange.FutureDays -gt 365)
    {
        Write-PSFMessage -Level Error -Message "Invalid configuration: DateRange.FutureDays must be between 1 and 365"
        $isValid = $false
    }
    
    if ($isValid)
    {
        Write-PSFMessage -Level Debug -Message "Configuration validation passed"
    }
    
    return $isValid
}
