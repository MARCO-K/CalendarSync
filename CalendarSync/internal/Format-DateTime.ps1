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
        Use short format for output (dd.MM.yy instead of dd.MM.yyyy)
    .PARAMETER Format
        Custom format string (default: dd.MM.yyyy)
    .PARAMETER PreserveDateOnly
        When true, preserves the date component without timezone conversion (useful for calendar dates)
    .EXAMPLE
        Format-DateTime -DateTimeString "2025-07-17T09:00:00Z"
    .EXAMPLE
        Format-DateTime -DateTimeString "2025-07-17T09:00:00Z" -ShortFormat
    .EXAMPLE
        Format-DateTime -DateTimeString "2025-07-17T23:59:00Z" -PreserveDateOnly
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$DateTimeString,

        [switch]$ShortFormat,

        [string]$Format = "dd.MM.yyyy",

        [switch]$PreserveDateOnly
    )

    if ([string]::IsNullOrEmpty($DateTimeString))
    {
        return $null
    }

    try
    {
        [DateTime]$dateTime = [DateTime]::MinValue

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

        # Convert to local time if UTC (unless PreserveDateOnly is specified)
        if ($dateTime.Kind -eq [DateTimeKind]::Utc -and -not $PreserveDateOnly)
        {
            $dateTime = $dateTime.ToLocalTime()
        }

        # Use short format if requested
        if ($ShortFormat)
        {
            $outputFormat = "dd.MM.yy"
        }
        else
        {
            $outputFormat = $Format
        }

        return $dateTime.ToString($outputFormat)
    }
    catch
    {
        Write-PSFMessage -Level Warning -Message "Failed to parse datetime '$DateTimeString': $($_.Exception.Message)"
        return $DateTimeString
    }
}
