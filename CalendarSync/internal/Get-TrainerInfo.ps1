function Get-TrainerInfo {
    <#
    .SYNOPSIS
        Extracts trainer information from subject strings
    .DESCRIPTION
        Uses regex patterns to extract trainer names from event subject lines
    .PARAMETER SubjectString
        Subject string containing trainer information
    .EXAMPLE
        Get-TrainerInfo -SubjectString "PowerBI Grundlagen - Trainer: Jan Trummel"
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$SubjectString
    )

    if ([string]::IsNullOrEmpty($SubjectString)) {
        return $null
    }

    try {
        # Pattern to match "Trainer: Name" or "Trainer von Name"
        if ($SubjectString -match 'Trainer:\s*([^-]+?)(?:\s*$|$)') {
            $trainer = $matches[1].Trim()
            Write-PSFMessage -Level Debug -Message "Extracted trainer from subject: '$trainer'"
            return $trainer
        }
        elseif ($SubjectString -match 'Trainer\s+von\s+([^-]+?)(?:\s*$|$)') {
            $trainer = $matches[1].Trim()
            Write-PSFMessage -Level Debug -Message "Extracted trainer from subject (von pattern): '$trainer'"
            return $trainer
        }
        else {
            Write-PSFMessage -Level Debug -Message "No trainer pattern found in subject: '$SubjectString'"
            return $null
        }
    }
    catch {
        Write-PSFMessage -Level Debug -Message "Failed to extract trainer from subject: $($_.Exception.Message)"
        return $null
    }
}
