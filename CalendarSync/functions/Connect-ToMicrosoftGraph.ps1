function Connect-ToMicrosoftGraph {
    <#
    .SYNOPSIS
        Connects to Microsoft Graph API
    .DESCRIPTION
        Establishes connection to Microsoft Graph with retry logic and proper scopes
    .PARAMETER MaxRetries
        Maximum number of connection attempts (default: 3)
    .PARAMETER RetryDelaySeconds
        Delay between retry attempts in seconds (default: 5)
    .EXAMPLE
        Connect-ToMicrosoftGraph -MaxRetries 5 -RetryDelaySeconds 10
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [int]$MaxRetries = 3,
        [int]$RetryDelaySeconds = 5
    )

    try {
        Write-PSFMessage -Level Verbose -Message "Connecting to Microsoft Graph..."

        # Check if already connected
        $context = Get-MgContext -ErrorAction SilentlyContinue
        if ($context) {
            Write-PSFMessage -Level Verbose -Message "Already connected to Microsoft Graph as: $($context.Account)"
            return $true
        }

        # Retry logic for connection
        for ($i = 1; $i -le $MaxRetries; $i++) {
            try {
                Connect-MgGraph -Scopes "Sites.Read.All", "Sites.ReadWrite.All" -ErrorAction Stop
                Write-PSFMessage -Level Verbose -Message "Successfully connected to Microsoft Graph"
                return $true
            }
            catch {
                Write-PSFMessage -Level Warning -Message "Connection attempt $i failed: $($_.Exception.Message)"

                if ($i -eq $MaxRetries) {
                    throw
                }

                Write-PSFMessage -Level Verbose -Message "Retrying in $RetryDelaySeconds seconds..."
                Start-Sleep -Seconds $RetryDelaySeconds
            }
        }

        return $false
    }
    catch {
        Write-PSFMessage -Level Error -Message "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
        return $false
    }
}
