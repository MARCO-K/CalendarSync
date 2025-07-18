function Get-TrainerInfo
{
    <#
    .SYNOPSIS
        Extracts trainer information from subject strings and looks up trainer details.
    .DESCRIPTION
        Uses regex patterns to extract trainer names from event subject lines,
        then searches a JSON file for a matching trainer.
    .PARAMETER SubjectString
        Subject string containing trainer information.
    .EXAMPLE
        Get-TrainerInfo -SubjectString "PowerBI Grundlagen - Trainer: Marco Kleinert"
    #>
    [CmdletBinding()]
    [OutputType([object])]
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
        # Extract the trainer name from the subject
        $extractedTrainerName = $null
        if ($SubjectString -match 'Trainer:\s*([^-]+?)(?:\s*$|$)')
        {
            $extractedTrainerName = $matches[1].Trim()
        }
        elseif ($SubjectString -match 'Trainer\s+von\s+([^-]+?)(?:\s*$|$)')
        {
            $extractedTrainerName = $matches[1].Trim()
        }

        if ([string]::IsNullOrEmpty($extractedTrainerName))
        {
            Write-PSFMessage -Level Debug -Message "No trainer pattern found in subject: '$SubjectString'"
            return $null
        }

        Write-PSFMessage -Level Debug -Message "Extracted trainer name: '$extractedTrainerName'"

        # Load trainer data
        $trainerLookupPath = Join-Path -Path $PSScriptRoot -ChildPath "..\trainers.json"
        if (-not (Test-Path $trainerLookupPath)) {
            Write-PSFMessage -Level Debug -Message "Trainer lookup file not found at '$trainerLookupPath'. Returning extracted name."
            return [PSCustomObject]@{ID = $null; FirstName = $extractedTrainerName; LastName = ''; FullName = $extractedTrainerName }
        }
        $trainers = Get-Content -Path $trainerLookupPath -Encoding UTF8 | ConvertFrom-Json

        # Find matching trainer
        foreach ($trainer in $trainers) {
            $fullName = "$($trainer.FirstName) $($trainer.LastName)"
            if ($extractedTrainerName -like "*$($trainer.FirstName)*" -or $extractedTrainerName -like "*$($trainer.LastName)*" -or $extractedTrainerName -like "*$fullName*") {
                
                Write-PSFMessage -Level Debug -Message "Found matching trainer: $($trainer.LastName), $($trainer.FirstName) (ID: $($trainer.ID))"
                return $trainer | Select-Object *, @{Name = 'FullName'; Expression = { "$($_.LastName), $($_.FirstName)" } }
            }
        }

        Write-PSFMessage -Level Debug -Message "No entry found for '$extractedTrainerName' in lookup file. Returning extracted name."
        return [PSCustomObject]@{ID = $null; FirstName = $extractedTrainerName; LastName = ''; FullName = $extractedTrainerName }
    }
    catch
    {
        Write-PSFMessage -Level Error -Message "Failed to extract or look up trainer from subject: $($_.Exception.Message)"
        return $null
    }
}
