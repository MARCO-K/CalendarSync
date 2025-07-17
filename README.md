# CalendarSync PowerShell Module

A clean, modular PowerShell module for synchronizing calendar events from SharePoint lists using Microsoft Graph API.

## Features

- 🔧 **Modular Design** - Clean separation of public and internal functions
- 📊 **PSFramework Logging** - Standardized logging with multiple levels
- 🛡️ **Robust Error Handling** - Comprehensive error handling with retry logic
- ⚙️ **Configurable** - External JSON configuration support
- 🔍 **Debug Mode** - Enhanced debugging and troubleshooting
- 📤 **JSON Export** - Export results to timestamped JSON files
- 🔌 **Graph API Integration** - Optimized Microsoft Graph API usage
- 🎯 **SharePoint Integration** - Direct SharePoint list access

## Quick Start

```powershell
# Import the module
Import-Module .\CalendarSync

# Run calendar synchronization
Sync-CalendarEvents -DebugMode

# Get events programmatically
$events = Sync-CalendarEvents -OutputPath $null
```

## Requirements

- PowerShell 5.1 or higher
- Microsoft Graph PowerShell SDK
- PSFramework module
- Valid Microsoft 365 tenant access
- SharePoint permissions (Sites.Read.All, Sites.ReadWrite.All)

## Installation

### From Source

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/CalendarSync.git
   cd CalendarSync
   ```

2. Install required modules:

   ```powershell
   Install-Module Microsoft.Graph -Scope CurrentUser
   Install-Module PSFramework -Scope CurrentUser
   ```

3. Import the module:

   ```powershell
   Import-Module .\CalendarSync
   ```

### Using PowerShell Gallery (Future)

```powershell
Install-Module CalendarSync -Scope CurrentUser
```

## Usage

### Basic Usage

```powershell
# Basic synchronization
Sync-CalendarEvents

# With debug output
Sync-CalendarEvents -DebugMode

# Custom output directory
Sync-CalendarEvents -OutputPath "C:\Results"

# Using external configuration
Sync-CalendarEvents -ConfigPath ".\myconfig.json"
```

### Advanced Usage

```powershell
# Use individual functions
Connect-ToMicrosoftGraph
$items = Get-SharePointListItems -SiteID $siteId -ListID $listId -FilterString $filter -StartDate $start -EndDate $end -DateFieldName "EventDate" -FilterConfig $config
$events = ConvertTo-FormattedEvents -Items $items -FieldMappings $mappings
Export-ResultsToJson -Events $events -OutputPath ".\output"
```

## Configuration

Create a `config.json` file to customize the module behavior:

```json
{
    "SharePoint": {
        "ListID": "your-sharepoint-list-id",
        "SiteID": "your-sharepoint-site-id"
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

## Module Structure

```
CalendarSync/
├── CalendarSync.psd1          # Module manifest
├── CalendarSync.psm1          # Module loader
├── README.md                  # Module documentation
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

## Public Functions

### Sync-CalendarEvents

Main orchestration function that handles the complete synchronization process.

### Connect-ToMicrosoftGraph

Establishes connection to Microsoft Graph API with retry logic.

### Get-SharePointListItems

Retrieves SharePoint list items with advanced filtering capabilities.

### ConvertTo-FormattedEvents

Processes SharePoint items into standardized event objects.

### Export-ResultsToJson

Exports events to timestamped JSON files.

## Examples

### Basic Calendar Sync

```powershell
Sync-CalendarEvents
```

### Debugging Issues

```powershell
Sync-CalendarEvents -DebugMode -Verbose
```

### Custom Configuration

```powershell
Sync-CalendarEvents -ConfigPath ".\custom-config.json" -OutputPath "C:\CalendarExports"
```

## Error Handling

The module includes comprehensive error handling:

- **Retry Logic** - Automatic retry for transient failures
- **Graceful Degradation** - Fallback mechanisms for different scenarios
- **Detailed Logging** - Comprehensive logging for troubleshooting
- **Validation** - Input validation and configuration verification

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Report issues on [GitHub Issues](https://github.com/yourusername/CalendarSync/issues)
- Check the [documentation](CalendarSync/README.md) for detailed information
- Review the [changelog](CHANGELOG.md) for version history

## Acknowledgments

- Microsoft Graph PowerShell SDK team
- PSFramework developers
- SharePoint community
