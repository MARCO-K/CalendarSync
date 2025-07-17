function Sync-CalendarEvents {
    <#
    .SYNOPSIS
        Synchronizes calendar events from SharePoint lists
    .DESCRIPTION
        Main function that orchestrates the calendar synchronization process from SharePoint lists
        with configurable field mappings, error handling, and logging capabilities.
    .PARAMETER ConfigPath
        Path to configuration file (optional, defaults to embedded configuration)
    .PARAMETER OutputPath
        Path to output directory for JSON results (optional, defaults to script directory)
    .PARAMETER DebugMode
        Enable debug output and detailed logging
    .EXAMPLE
        Sync-CalendarEvents -DebugMode
    .EXAMPLE
        Sync-CalendarEvents -ConfigPath ".\config.json" -OutputPath ".\results\"
    #>
    [CmdletBinding()]
    param(
        [ValidateScript({
            if ([string]::IsNullOrEmpty($_)) { return $true }
            if (-not (Test-Path $_)) { throw "Configuration file not found: $_" }
            if (-not $_.EndsWith('.json')) { throw "Configuration file must be a JSON file: $_" }
            return $true
        })]
        [string]$ConfigPath = "",
        
        [ValidateScript({
            if ([string]::IsNullOrEmpty($_)) { return $true }
            $parent = Split-Path -Parent $_
            if ($parent -and -not (Test-Path $parent)) { throw "Output directory does not exist: $parent" }
            return $true
        })]
        [string]$OutputPath = "",
        
        [switch]$DebugMode = $false
    )
    
    try {
        # Initialize logging
        Write-PSFMessage -Level Verbose -Message "=== Calendar Sync Process Started ==="
        
        # Load configuration
        $Config = Get-Configuration -ConfigPath $ConfigPath
        
        # Connect to Microsoft Graph
        if (-not (Connect-ToMicrosoftGraph)) {
            throw "Failed to establish Microsoft Graph connection"
        }
        
        # Calculate date range for upcoming week
        $startDateObj = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0  # Start of today
        $endDateObj = $startDateObj.AddDays($Config.DateRange.FutureDays).AddHours(23).AddMinutes(59).AddSeconds(59)  # End of 7th day
        $startDate = $startDateObj.ToString("yyyy-MM-ddTHH:mm:ssZ")
        $endDate = $endDateObj.ToString("yyyy-MM-ddTHH:mm:ssZ")
        
        Write-PSFMessage -Level Verbose -Message "Upcoming week date range: $startDate to $endDate"
        
        # Build filter string for upcoming week (both start and end constraints)
        $filterString = "fields/$($Config.FieldMappings.StartDate) ge '$startDate' and fields/$($Config.FieldMappings.StartDate) le '$endDate'"
        
        # Get SharePoint list items
        $events = Get-SharePointListItems -SiteID $Config.SharePoint.SiteID -ListID $Config.SharePoint.ListID -FilterString $filterString -StartDate $startDateObj -EndDate $endDateObj -DateFieldName $Config.FieldMappings.StartDate -FilterConfig $Config.Filtering
        
        # Process and format events
        $formattedEvents = ConvertTo-FormattedEvents -Items $events -FieldMappings $Config.FieldMappings
        
        # Export results if events found
        if ($formattedEvents.Count -gt 0) {
            $outputPath = if ($OutputPath) { 
                $OutputPath 
            }
            else { 
                $scriptPath = if ($MyInvocation.ScriptName) { 
                    Split-Path -Parent $MyInvocation.ScriptName 
                }
                else { 
                    Get-Location 
                }
                $scriptPath
            }
            Export-ResultsToJson -Events $formattedEvents -OutputPath $outputPath
        }
        
        # Output results
        Write-PSFMessage -Level Verbose -Message "=== SYNC RESULTS ==="
        Write-PSFMessage -Level Verbose -Message "Total events processed: $($formattedEvents.Count)"
        
        if ($DebugMode -and $formattedEvents.Count -gt 0) {
            Write-PSFMessage -Level Debug -Message "=== DEBUG: First 3 Events ==="
            $debugOutput = $formattedEvents | Select-Object -First 3 | Format-List | Out-String
            Write-PSFMessage -Level Debug -Message $debugOutput
        }
        
        # Return formatted events for further processing only if not writing to JSON
        if (-not $OutputPath) {
            return $formattedEvents
        }
    }
    catch {
        Write-PSFMessage -Level Error -Message "Calendar sync process failed: $_"
        Write-PSFMessage -Level Error -Message "Stack trace: $($_.ScriptStackTrace)"
        throw
    }
    finally {
        Write-PSFMessage -Level Verbose -Message "=== Calendar Sync Process Completed ==="
    }
}
