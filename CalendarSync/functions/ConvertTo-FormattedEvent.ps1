function ConvertTo-FormattedEvent
{
    <#
    .SYNOPSIS
        Converts SharePoint list items to formatted event objects
    .DESCRIPTION
        Processes SharePoint list items and converts them to standardized event objects with extracted information
        including trainer and account information
    .PARAMETER Items
        Array of SharePoint list items to process
    .PARAMETER FieldMappings
        Hashtable mapping field names to SharePoint field names
    .EXAMPLE
        ConvertTo-FormattedEvent -Items $items -FieldMappings $config.FieldMappings
    #>
    [CmdletBinding()]
    [OutputType([array])]
    param(
        [Parameter(Mandatory = $true)]
        [array]$Items,

        [Parameter(Mandatory = $true)]
        [hashtable]$FieldMappings
    )

    $formattedEvents = @()

    foreach ($item in $Items)
    {
        try
        {
            $fields = $item.Fields.AdditionalProperties

            # Debug output for field discovery
            if ($DebugMode)
            {
                Write-PSFMessage -Level Debug -Message "Processing Item ID: $($item.Id)"
                Write-PSFMessage -Level Debug -Message "Available fields: $($fields.Keys -join ', ')"
            }

            # Create formatted event with safe field access
            $rawStartDate = Get-SafeFieldValue -Fields $fields -FieldName $FieldMappings.StartDate
            $rawEndDate = Get-SafeFieldValue -Fields $fields -FieldName $FieldMappings.EndDate

            # Extract event times from location
            $location = Get-SafeFieldValue -Fields $fields -FieldName $FieldMappings.Location
            $eventTimes = Get-EventTime -LocationString $location

            # Clean HTML content from Description
            $rawDescription = Get-SafeFieldValue -Fields $fields -FieldName $FieldMappings.Description
            $cleanDescription = Convert-HtmlToText -HtmlContent $rawDescription

            # Extract trainer information from subject
            $subject = Get-SafeFieldValue -Fields $fields -FieldName $FieldMappings.Title
            $trainer = Get-TrainerInfo -SubjectString $subject

            # Extract account information from subject
            $account = Get-AccountInfo -SubjectString $subject

            # Determine location type
            $locationType = Get-LocationType -LocationString $location

            $formattedEvents += [PSCustomObject]@{
                Id           = $item.Id
                Subject      = $subject
                Description  = $cleanDescription
                StartDate    = Format-DateTime -DateTimeString $rawStartDate
                EndDate      = Format-DateTime -DateTimeString $rawEndDate
                StartTime    = $eventTimes.StartTime
                EndTime      = $eventTimes.EndTime
                Location     = $location
                LocationType = $locationType
                Trainer      = $trainer
                Account      = $account
            }

        }
        catch
        {
            Write-PSFMessage -Level Error -Message "Error processing item $($item.Id): $($_.Exception.Message)"
            Write-PSFMessage -Level Debug -Message "Stack trace: $($_.ScriptStackTrace)"
        }
    }

    Write-PSFMessage -Level Verbose -Message "Successfully processed $($formattedEvents.Count) events"

    return $formattedEvents
}
