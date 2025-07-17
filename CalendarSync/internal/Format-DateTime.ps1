function Format-DateTime
{
    <#
    .SYNOPSIS
        Formats datetime strings with timezone handling
    .DESCRIPTION
        Parses and formats datetime strings with support for ISO 8601 and other formats
    .PARAMETER DateTimeString
        String containing the datetime to format
    .PARAMETER ShortFormat
        Use short format for output
    .PARAMETER Format
        Custom format string (default: dd.MM.yyyy)
    .EXAMPLE
        Format-DateTime -DateTimeString "2025-07-17T09:00:00Z"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$DateTimeString,
        
        [switch]$ShortFormat,
        
        [string]$Format = "dd.MM.yyyy"
    )
    
    if ([string]::IsNullOrEmpty($DateTimeString))
    {
        return $null
    }
    
    try
    {
        $dateTime = $null
        
        # Handle ISO 8601 format with Z suffix (UTC)
        if ($DateTimeString -match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?$')
        {
            $dateTime = [DateTime]::Parse($DateTimeString, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
        }
        # Handle other standard formats
        elseif ([DateTime]::TryParse($DateTimeString, [ref]$dateTime))
        {
            # Successfully parsed
        }
        else
        {
            Write-PSFMessage -Level Warning -Message "Unable to parse datetime format: $DateTimeString"
            return $DateTimeString
        }
        
        # Convert to local time if UTC
        if ($dateTime.Kind -eq [DateTimeKind]::Utc)
        {
            $dateTime = $dateTime.ToLocalTime()
        }
        
        return $dateTime.ToString($Format)
    }
    catch
    {
        Write-PSFMessage -Level Warning -Message "Failed to parse datetime '$DateTimeString': $($_.Exception.Message)"
        return $DateTimeString
    }
}
