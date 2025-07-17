# CalendarSync PowerShell Module

A modular PowerShell module for synchronizing calendar events between Microsoft Graph API and SharePoint lists with
enhanced error handling, logging, and configuration management.

## Module Structure

```
CalendarSync/
├── CalendarSync.psd1          # Module manifest
├── CalendarSync.psm1          # Main module file
├── functions/                 # Public functions
│   ├── Sync-CalendarEvents.ps1
│   ├── Connect-ToMicrosoftGraph.ps1
│   ├── Get-SharePointListItems.ps1
│   ├── ConvertTo-FormattedEvents.ps1
│   └── Export-ResultsToJson.ps1
└── internal/                  # Helper functions
    ├── DefaultConfig.ps1
    ├── Get-Configuration.ps1
    ├── Test-Configuration.ps1
    ├── Get-SafeFieldValue.ps1
    ├── Format-DateTime.ps1
    ├── Get-EventTimes.ps1
    ├── Convert-HtmlToText.ps1
    ├── Get-TrainerInfo.ps1
    └── Get-LocationType.ps1
```

## Features

- 🔧 **Modular Design** - Clean separation of public and internal functions
- 📊 **Comprehensive Logging** - Uses PSFramework for standardized logging
- 🛡️ **Error Handling** - Robust error handling with detailed error messages
- ⚙️ **External Configuration** - Support for JSON configuration files
- 🔍 **Debug Mode** - Enhanced debugging output for troubleshooting
- 📤 **JSON Export** - Export results to JSON files for further processing
- 🔌 **Graph API Integration** - Optimized Microsoft Graph API usage

## Installation

1. Copy the CalendarSync folder to your PowerShell modules directory:

   ```powershell
   # For current user
   Copy-Item -Path ".\CalendarSync" -Destination "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\" -Recurse
   
   # For all users (requires admin)
   Copy-Item -Path ".\CalendarSync" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\" -Recurse
   ```

2. Or import directly from the current location:

   ```powershell
   Import-Module ".\CalendarSync"
   ```

## Usage

### Basic Usage

```powershell
# Import the module
Import-Module CalendarSync

# Run synchronization
Sync-CalendarEvents

# Run with debug mode
Sync-CalendarEvents -DebugMode
```

### Advanced Usage

```powershell
# Use external configuration file
Sync-CalendarEvents -ConfigPath ".\config.json"

# Specify output directory
Sync-CalendarEvents -OutputPath ".\results\"

# Get events programmatically (without file output)
$events = Sync-CalendarEvents -OutputPath $null
```

### Individual Function Usage

```powershell
# Connect to Microsoft Graph
Connect-ToMicrosoftGraph

# Get SharePoint list items
$items = Get-SharePointListItems -SiteID $siteId -ListID $listId -FilterString $filter

# Convert to formatted events
$events = ConvertTo-FormattedEvents -Items $items -FieldMappings $mappings

# Export to JSON
Export-ResultsToJson -Events $events -OutputPath ".\output"
```

## Public Functions

### Sync-CalendarEvents

Main function that orchestrates the entire synchronization process.

**Parameters:**

- `ConfigPath` - Path to JSON configuration file (optional)
- `OutputPath` - Output directory for JSON results (optional)
- `DebugMode` - Enable debug logging (switch)

### Connect-ToMicrosoftGraph

Establishes connection to Microsoft Graph API with retry logic.

**Parameters:**

- `MaxRetries` - Maximum connection attempts (default: 3)
- `RetryDelaySeconds` - Delay between retries (default: 5)

### Get-SharePointListItems

Retrieves SharePoint list items with filtering support.

**Parameters:**

- `SiteID` - SharePoint site ID
- `ListID` - SharePoint list ID
- `FilterString` - OData filter string
- `StartDate` - Filter start date
- `EndDate` - Filter end date
- `DateFieldName` - Date field name for filtering
- `FilterConfig` - Filtering configuration

### ConvertTo-FormattedEvents

Converts SharePoint items to formatted event objects.

**Parameters:**

- `Items` - Array of SharePoint items
- `FieldMappings` - Field mapping configuration

### Export-ResultsToJson

Exports events to timestamped JSON file.

**Parameters:**

- `Events` - Array of events to export
- `OutputPath` - Output directory path

## Configuration

The module uses a default configuration that can be overridden with a JSON file:

```json
{
    "SharePoint": {
        "ListID": "your-list-id",
        "SiteID": "your-site-id"
    },
    "DateRange": {
        "PastDays": 0,
        "FutureDays": 7
    },
    "FieldMappings": {
        "Title": "Title",
        "Description": "Description",
        "StartDate": "EventDate",
        "EndDate": "EndDate",
        "Location": "Location"
    },
    "Filtering": {
        "PreferServerSide": true,
        "AllowNonIndexedQueries": true,
        "FallbackToClientSide": true
    }
}
```

## Requirements

- PowerShell 5.1 or higher
- Microsoft Graph PowerShell SDK
- PSFramework module
- Appropriate SharePoint permissions
- Valid Microsoft 365 tenant access

## Compatibility

A compatibility script (`CalendarSync-New.ps1`) is provided that mimics the original script behavior while using the
modular functions underneath.

## Error Handling

The module includes comprehensive error handling with:

- Detailed error messages
- Stack trace information
- Graceful fallback mechanisms
- Retry logic for API calls

## Logging

Uses PSFramework for standardized logging with support for:

- Verbose output
- Debug messages
- Warning notifications
- Error reporting

## Contributing

When adding new functions:

1. Place public functions in the `functions/` directory
2. Place helper functions in the `internal/` directory
3. Update the module manifest (`CalendarSync.psd1`) to export new public functions
4. Follow PowerShell best practices for function naming and parameter validation
