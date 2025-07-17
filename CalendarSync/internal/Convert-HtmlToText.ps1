function Convert-HtmlToText
{
    <#
    .SYNOPSIS
        Converts HTML content to plain text
    .DESCRIPTION
        Removes HTML tags, CSS styles, and decodes HTML entities to produce clean text
    .PARAMETER HtmlContent
        HTML content to convert to plain text
    .EXAMPLE
        Convert-HtmlToText -HtmlContent "<p>Hello <b>World</b></p>"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$HtmlContent
    )
    
    if ([string]::IsNullOrEmpty($HtmlContent))
    {
        return $null
    }
    
    try
    {
        # Remove CSS style rules (e.g., "p.MsoNormal { ... }")
        $content = $HtmlContent -replace '[a-zA-Z0-9\.\-_#:,\s]+\s*\{[^}]*\}', ''
        
        # Remove remaining CSS fragments
        $content = $content -replace '[\w\.\-_#:,\s]*\s*\{[^}]*\}', ''
        
        # Replace paragraph tags with line breaks
        $content = $content -replace '<p[^>]*>', "`n"
        $content = $content -replace '</p>', "`n"
        
        # Replace div tags with line breaks
        $content = $content -replace '<div[^>]*>', "`n"
        $content = $content -replace '</div>', ""
        
        # Replace line break tags with actual line breaks
        $content = $content -replace '<br[^>]*/?>', "`n"
        
        # Replace table rows with line breaks
        $content = $content -replace '<tr[^>]*>', "`n"
        $content = $content -replace '</tr>', ""
        
        # Replace table cells with tabs
        $content = $content -replace '<td[^>]*>', "`t"
        $content = $content -replace '</td>', ""
        
        # Replace table headers with tabs
        $content = $content -replace '<th[^>]*>', "`t"
        $content = $content -replace '</th>', ""
        
        # Remove all remaining HTML tags
        $content = $content -replace '<[^>]+>', ''
        
        # Decode HTML entities
        $content = $content -replace '&lt;', '<'
        $content = $content -replace '&gt;', '>'
        $content = $content -replace '&amp;', '&'
        $content = $content -replace '&quot;', '"'
        $content = $content -replace '&apos;', "'"
        $content = $content -replace '&#58;', ':'
        $content = $content -replace '&#160;', ' '
        $content = $content -replace '&nbsp;', ' '
        
        # Clean up excessive whitespace and line breaks
        $content = $content -replace '\s+', ' '
        $content = $content -replace '\n\s*\n', "`n`n"
        $content = $content.Trim()
        
        # Remove any remaining CSS selectors or fragments
        $content = $content -replace '^[a-zA-Z0-9\.\-_#:,\s]+\s*$', ''
        
        Write-PSFMessage -Level Debug -Message "Cleaned HTML content: $($content.Length) characters"
        return $content
    }
    catch
    {
        Write-PSFMessage -Level Debug -Message "Failed to clean HTML content: $($_.Exception.Message)"
        return $HtmlContent
    }
}
