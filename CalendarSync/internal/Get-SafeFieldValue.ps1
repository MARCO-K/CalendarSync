function Get-SafeFieldValue
{
    <#
    .SYNOPSIS
        Safely retrieves a field value from a hashtable
    .DESCRIPTION
        Gets a field value from a hashtable with null checking and warning if field doesn't exist
    .PARAMETER Fields
        Hashtable containing field values
    .PARAMETER FieldName
        Name of the field to retrieve
    .EXAMPLE
        Get-SafeFieldValue -Fields $item.Fields -FieldName "Title"
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [hashtable]$Fields,
        [string]$FieldName
    )

    if ($Fields.ContainsKey($FieldName))
    {
        return $Fields[$FieldName]
    }
    else
    {
        Write-PSFMessage -Level Warning -Message "Field '$FieldName' not found in item fields"
        return $null
    }
}
