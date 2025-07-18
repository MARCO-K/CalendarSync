function Get-AccountInfo
{
    <#
    .SYNOPSIS
        Extracts account information from subject strings
    .DESCRIPTION
        Uses regex patterns to extract account/company names from event subject lines
        Handles special cases like "Offen! Excel" and "PCC Berlin / Ärztekammer Nds."
    .PARAMETER SubjectString
        Subject string containing account information
    .EXAMPLE
        Get-AccountInfo -SubjectString "Bergmann Automotive GmbH - Programmieren mit IQ-Works  - Trainer: Daniel Wiehenkel"
    .EXAMPLE
        Get-AccountInfo -SubjectString "Offen! Excel - Grundlagen"
    .EXAMPLE
        Get-AccountInfo -SubjectString "PCC Berlin / Ärztekammer Nds. - Kurs"
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$SubjectString
    )

    if ([string]::IsNullOrEmpty($SubjectString))
    {
        return $null
    }

    try
    {
        # Special case: "ABGESAGT" -> return null
        if ($SubjectString -match 'ABGESAGT')
        {
            Write-PSFMessage -Level Debug -Message "Detected 'ABGESAGT' pattern, returning null"
            return $null
        }

        # Special case: "Offen! Excel" -> return "offen" (can be anywhere in subject)
        if ($SubjectString -like '*Offen!*')
        {
            Write-PSFMessage -Level Debug -Message "Detected 'Offen!' pattern, returning 'offen'"
            return "offen"
        }

        # Special case: "PCC Berlin / Company Name" -> return "Company Name"
        if ($SubjectString -match '^PCC\s+[^/]+/\s*([^-]+?)(?:\s*-|$)')
        {
            $account = $matches[1].Trim()
            Write-PSFMessage -Level Debug -Message "Extracted account from PCC pattern: '$account'"
            return $account
        }

        # General pattern: Extract text before the first " - " (dash separator)
        if ($SubjectString -match '^([^-]+?)\s*-')
        {
            $account = $matches[1].Trim()
            Write-PSFMessage -Level Debug -Message "Extracted account from subject: '$account'"
            return $account
        }

        # If no pattern matches, return nothing
        Write-PSFMessage -Level Debug -Message "No account pattern found in subject: '$SubjectString'"
        return $null
    }
    catch
    {
        Write-PSFMessage -Level Debug -Message "Failed to extract account from subject: $($_.Exception.Message)"
        return $null
    }
}
