# Default configuration for CalendarSync module
$script:DefaultConfig = @{
    SharePoint    = @{
        ListID = '7ee97012-82fa-4c24-a127-3d774f3bdd3c'
        SiteID = 'root'
    }
    DateRange     = @{
        PastDays   = 0      # Start from today (no past events)
        FutureDays = 7      # Next 7 days (upcoming week)
    }
    FieldMappings = @{
        Title       = 'Title'
        Description = 'Description'
        StartDate   = 'EventDate'
        EndDate     = 'EndDate'
        Location    = 'Location'
    }
    Filtering     = @{
        PreferServerSide       = $true
        AllowNonIndexedQueries = $true
        FallbackToClientSide   = $true
    }
    Logging       = @{
        EnableConsoleOutput = $true
        EnableFileOutput    = $true
        LogLevel            = 'INFO'  # DEBUG, INFO, WARNING, ERROR
    }
}
