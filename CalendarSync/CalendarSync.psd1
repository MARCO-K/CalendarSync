@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'CalendarSync.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0.0'

    # ID used to uniquely identify this module
    GUID              = 'b9c85b6d-4f6e-4a8d-9c7e-8f1a2b3c4d5e'

    # Author of this module
    Author            = 'Calendar Sync Team'

    # Company or vendor of this module
    CompanyName       = 'Netz-Weise'

    # Copyright statement for this module
    Copyright         = '(c) 2025 Calendar Sync Team. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'PowerShell module for synchronizing calendar events between Microsoft Graph API and SharePoint lists with enhanced error handling, logging, and configuration management.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules   = @(
        'Microsoft.Graph.Authentication',
        'Microsoft.Graph.Sites',
        'PSFramework'
    )

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'Sync-CalendarEvents',
        'Connect-ToMicrosoftGraph',
        'Get-SharePointListItems',
        'ConvertTo-FormattedEvents',
        'Export-ResultsToJson'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('Calendar', 'SharePoint', 'Graph', 'Sync', 'Microsoft365')

            # A URL to the license for this module.
            LicenseUri   = ''

            # A URL to the main website for this project.
            ProjectUri   = ''

            # A URL to an icon representing this module.
            IconUri      = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release with modular structure and comprehensive functionality.'
        }
    }
}
