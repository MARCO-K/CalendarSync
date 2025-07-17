function Get-EventTimes
{
    <#
    .SYNOPSIS
        Extracts start and end times from location strings
    .DESCRIPTION
        Uses regex patterns to extract time ranges from location descriptions
    .PARAMETER LocationString
        String containing location and time information
    .EXAMPLE
        Get-EventTimes -LocationString "Netz-Weise, Zeiten: 09:00 - 16:00 Uhr"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$LocationString
    )
    
    $result = @{
        StartTime = $null
        EndTime   = $null
    }
    
    if ([string]::IsNullOrEmpty($LocationString))
    {
        return $result
    }
    
    try
    {
        # Pattern to match time ranges like "09:00 - 16:00 Uhr" or "6:00 - 14:00 Uhr"
        $timePattern = '(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})\s*Uhr'
        
        if ($LocationString -match $timePattern)
        {
            $startHour = $matches[1].PadLeft(2, '0')
            $startMinute = $matches[2]
            $endHour = $matches[3].PadLeft(2, '0')
            $endMinute = $matches[4]
            
            $result.StartTime = "${startHour}:${startMinute}"
            $result.EndTime = "${endHour}:${endMinute}"
        }
        # Alternative pattern for ranges like "09:00 - 12:00 Uhr und 13:00 - 16:00 Uhr"
        elseif ($LocationString -match '(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})\s*Uhr\s*und\s*(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})\s*Uhr')
        {
            $startHour = $matches[1].PadLeft(2, '0')
            $startMinute = $matches[2]
            $endHour = $matches[7].PadLeft(2, '0')
            $endMinute = $matches[8]
            
            $result.StartTime = "${startHour}:${startMinute}"
            $result.EndTime = "${endHour}:${endMinute}"
        }
        
        Write-PSFMessage -Level Debug -Message "Extracted times from '$LocationString': Start=$($result.StartTime), End=$($result.EndTime)"
    }
    catch
    {
        Write-PSFMessage -Level Debug -Message "Failed to extract times from location: $LocationString - Error: $($_.Exception.Message)"
    }
    
    return $result
}
