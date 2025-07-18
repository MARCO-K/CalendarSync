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

            # Detect and correct single-day events
            # SharePoint sometimes sets EndDate to next day instead of same day for single-day events
            if (-not [string]::IsNullOrEmpty($rawStartDate) -and -not [string]::IsNullOrEmpty($rawEndDate))
            {
                try
                {
                    $startDateTime = [DateTime]::Parse($rawStartDate, [System.Globalization.CultureInfo]::InvariantCulture)
                    $endDateTime = [DateTime]::Parse($rawEndDate, [System.Globalization.CultureInfo]::InvariantCulture)
                    
                    # Only correct if end date is exactly one day after start date
                    # AND this looks like a single-day event incorrectly spanning to next day
                    if ($endDateTime.Date -eq $startDateTime.Date.AddDays(1))
                    {
                        # Check if this looks like a single-day event that was incorrectly set:
                        # - Start time is typically morning (6:00-12:00)
                        # - End time is typically afternoon/evening (12:00-18:00)
                        # - The difference between start and end times (ignoring date) suggests a single working day
                        $startHour = $startDateTime.Hour
                        $endHour = $endDateTime.Hour
                        
                        # Calculate what the duration would be if it were the same day
                        $sameDayDuration = $endDateTime.TimeOfDay - $startDateTime.TimeOfDay
                        if ($sameDayDuration.TotalSeconds -lt 0)
                        {
                            $sameDayDuration = $sameDayDuration.Add([TimeSpan]::FromDays(1))
                        }
                        
                        if ($startHour -ge 6 -and $startHour -le 12 -and 
                            $endHour -ge 12 -and $endHour -le 18 -and
                            $sameDayDuration.TotalHours -ge 4 -and $sameDayDuration.TotalHours -le 12)
                        {
                            # Correct the end date to be the same as start date but keep the time
                            $correctedEndDate = $startDateTime.Date.Add($endDateTime.TimeOfDay)
                            $rawEndDate = $correctedEndDate.ToString("yyyy-MM-ddTHH:mm:ssZ")
                            Write-PSFMessage -Level Verbose -Message "Corrected single-day event: EndDate changed from $endDateTime to $correctedEndDate for item $($item.Id) (Duration: $($sameDayDuration.TotalHours) hours)"
                        }
                    }
                }
                catch
                {
                    Write-PSFMessage -Level Verbose -Message "Failed to parse dates for single-day event detection on item $($item.Id): $($_.Exception.Message)"
                }
            }

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
                StartDate    = Format-DateTime -DateTimeString $rawStartDate -PreserveDateOnly
                EndDate      = Format-DateTime -DateTimeString $rawEndDate -PreserveDateOnly
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
