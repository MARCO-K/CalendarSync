# Changelog

All notable changes to the CalendarSync PowerShell module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-07-17

### Added
- Initial release of CalendarSync PowerShell module
- Modular architecture with public and internal functions
- SharePoint list integration via Microsoft Graph API
- Configurable field mappings via JSON configuration
- PSFramework integration for standardized logging
- Comprehensive error handling with retry logic
- Support for server-side and client-side filtering
- HTML/CSS content cleaning for description fields
- Automatic time extraction from location strings
- Trainer information extraction from subject lines
- Location type categorization (Online/Netz-Weise/vor Ort)
- JSON export functionality with timestamped files
- Debug mode for enhanced troubleshooting
- Verbose logging throughout the module

### Public Functions
- `Sync-CalendarEvents` - Main orchestration function
- `Connect-ToMicrosoftGraph` - Graph API connection with retry logic
- `Get-SharePointListItems` - SharePoint data retrieval with filtering
- `ConvertTo-FormattedEvents` - Event processing and formatting
- `Export-ResultsToJson` - JSON export functionality

### Internal Functions
- `Get-Configuration` - Configuration management
- `Test-Configuration` - Configuration validation
- `Get-SafeFieldValue` - Safe field value extraction
- `Format-DateTime` - DateTime formatting with timezone handling
- `Get-EventTimes` - Time extraction from location strings
- `Convert-HtmlToText` - HTML/CSS content cleaning
- `Get-TrainerInfo` - Trainer extraction from subject lines
- `Get-LocationType` - Location type categorization

### Features
- Server-side filtering with non-indexed query support
- Client-side filtering fallback
- Configurable date range filtering
- Comprehensive input validation
- Graceful error handling and recovery
- Detailed logging at multiple levels
- Module manifest with proper dependencies
- PowerShell Gallery ready structure

### Documentation
- Comprehensive module documentation
- Function help with examples
- Configuration reference
- Usage examples and best practices
- GitHub repository setup

## [Unreleased]

### Planned
- PowerShell Gallery publication
- Unit testing framework
- CI/CD pipeline integration
- Two-way synchronization support
- Email notification capabilities
- Scheduled execution support
- Additional output formats (CSV, XML)
- Enhanced error reporting
- Performance optimizations

---

## Version History

- **1.0.0** - Initial modular release with full functionality
- **0.x.x** - Development and prototyping phase (monolithic script)
