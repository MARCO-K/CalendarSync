function Get-LocationType {
    <#
    .SYNOPSIS
        Determines the location type based on location string
    .DESCRIPTION
        Categorizes locations as Netz-Weise, Online, or vor Ort based on content
    .PARAMETER LocationString
        Location string to analyze
    .EXAMPLE
        Get-LocationType -LocationString "Online via Teams"
    #>
    [CmdletBinding()]
    param(
        [string]$LocationString
    )
    
    if ([string]::IsNullOrEmpty($LocationString)) {
        return "vor Ort"
    }
    
    try {
        # Check for Netz-Weise location
        if ($LocationString -match "Netz-Weise") {
            Write-PSFMessage -Level Debug -Message "Location type detected as Netz-Weise for: '$LocationString'"
            return "Netz-Weise"
        }
        # Check for Online location
        elseif ($LocationString -match "Online") {
            Write-PSFMessage -Level Debug -Message "Location type detected as Online for: '$LocationString'"
            return "Online"
        }
        # Default to vor Ort for all other locations
        else {
            Write-PSFMessage -Level Debug -Message "Location type detected as vor Ort for: '$LocationString'"
            return "vor Ort"
        }
    }
    catch {
        Write-PSFMessage -Level Debug -Message "Failed to determine location type for: '$LocationString'. Error: $($_.Exception.Message)"
        return "vor Ort"
    }
}
