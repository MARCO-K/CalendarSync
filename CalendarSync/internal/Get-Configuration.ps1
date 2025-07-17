function Get-Configuration
{
    <#
    .SYNOPSIS
        Gets configuration for the Calendar Sync module
    .DESCRIPTION
        Loads configuration from external JSON file or uses default configuration
    .PARAMETER ConfigPath
        Path to the JSON configuration file
    .EXAMPLE
        Get-Configuration -ConfigPath ".\config.json"
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$ConfigPath
    )

    $config = $null

    if ($ConfigPath -and (Test-Path $ConfigPath))
    {
        try
        {
            $configContent = Get-Content $ConfigPath -Raw
            $config = $configContent | ConvertFrom-Json
            Write-PSFMessage -Level Verbose -Message "External configuration loaded from: $ConfigPath"
        }
        catch
        {
            Write-PSFMessage -Level Error -Message "Failed to load external configuration: $($_.Exception.Message)"
            Write-PSFMessage -Level Warning -Message "Using default configuration"
            $config = $DefaultConfig
        }
    }
    else
    {
        $config = $DefaultConfig
        Write-PSFMessage -Level Verbose -Message "Using default configuration"
    }

    # Validate configuration
    if (-not (Test-Configuration -Config $config))
    {
        throw "Configuration validation failed"
    }

    return $config
}
