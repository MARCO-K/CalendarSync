function Export-ResultsToJson {
    <#
    .SYNOPSIS
        Exports event results to JSON file
    .DESCRIPTION
        Converts event objects to JSON format and saves to timestamped file
    .PARAMETER Events
        Array of event objects to export
    .PARAMETER OutputPath
        Directory path where JSON file should be saved
    .EXAMPLE
        Export-ResultsToJson -Events $formattedEvents -OutputPath "C:\Results"
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [array]$Events,
        [string]$OutputPath
    )

    try {
        $outputFile = Join-Path $OutputPath "calendarSync_results_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
        $Events | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8
        Write-PSFMessage -Level Verbose -Message "Results exported to: $outputFile"
        return $outputFile
    }
    catch {
        Write-PSFMessage -Level Error -Message "Failed to export results: $_"
        return $null
    }
}
