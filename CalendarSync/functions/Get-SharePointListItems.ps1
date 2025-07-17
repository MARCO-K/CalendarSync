function Get-SharePointListItems {
    <#
    .SYNOPSIS
        Retrieves SharePoint list items with filtering support
    .DESCRIPTION
        Gets SharePoint list items with server-side or client-side filtering options
    .PARAMETER SiteID
        SharePoint site ID
    .PARAMETER ListID
        SharePoint list ID
    .PARAMETER FilterString
        OData filter string for server-side filtering
    .PARAMETER StartDate
        Start date for filtering events
    .PARAMETER EndDate
        End date for filtering events
    .PARAMETER DateFieldName
        Name of the date field to filter on
    .PARAMETER FilterConfig
        Configuration object for filtering behavior
    .EXAMPLE
        Get-SharePointListItems -SiteID $siteId -ListID $listId -FilterString $filter -StartDate $start -EndDate $end -DateFieldName "StartDate" -FilterConfig $config
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SiteID,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ListID,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FilterString,
        
        [Parameter(Mandatory = $true)]
        [datetime]$StartDate,
        
        [Parameter(Mandatory = $true)]
        [datetime]$EndDate,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DateFieldName,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$FilterConfig
    )
    
    try {
        Write-PSFMessage -Level Verbose -Message "Retrieving SharePoint list items..."
        
        # First attempt: Try with server-side filtering (if enabled)
        if ($FilterConfig.PreferServerSide) {
            try {
                Write-PSFMessage -Level Debug -Message "Attempting server-side filtering with: $FilterString"
                $items = Get-MgSiteListItem -SiteId $SiteID -ListId $ListID -Filter $FilterString -ExpandProperty Fields -All -ErrorAction Stop
                Write-PSFMessage -Level Verbose -Message "Successfully retrieved $($items.Count) items using server-side filtering"
                return $items
            }
            catch {
                Write-PSFMessage -Level Warning -Message "Server-side filtering failed: $_"
                
                # Check if it's the non-indexed field error and if non-indexed queries are allowed
                if ($_.Exception.Message -like "*not indexed*" -and $FilterConfig.AllowNonIndexedQueries) {
                    Write-PSFMessage -Level Warning -Message "Field '$DateFieldName' is not indexed. Attempting non-indexed query..."
                    
                    # Second attempt: Try with the special header for non-indexed queries
                    try {
                        Write-PSFMessage -Level Debug -Message "Attempting non-indexed query with special header..."
                        $headers = @{
                            "Prefer" = "HonorNonIndexedQueriesWarningMayFailRandomly"
                        }
                        
                        # Use Invoke-MgGraphRequest with custom headers
                        $graphUrl = "/sites/$SiteID/lists/$ListID/items?expand=fields&`$filter=$FilterString"
                        $response = Invoke-MgGraphRequest -Uri $graphUrl -Headers $headers -Method GET -ErrorAction Stop
                        
                        $items = $response.value | ForEach-Object {
                            [PSCustomObject]@{
                                Id     = $_.id
                                Fields = @{
                                    AdditionalProperties = $_.fields
                                }
                            }
                        }
                        
                        Write-PSFMessage -Level Verbose -Message "Successfully retrieved $($items.Count) items using non-indexed query"
                        return $items
                    }
                    catch {
                        Write-PSFMessage -Level Warning -Message "Non-indexed query also failed: $_"
                    }
                }
                
                # If server-side filtering fails and client-side fallback is not enabled, throw
                if (-not $FilterConfig.FallbackToClientSide) {
                    throw
                }
            }
        }
        
        # Fallback: Get all items and filter client-side (if enabled)
        if ($FilterConfig.FallbackToClientSide) {
            Write-PSFMessage -Level Warning -Message "Using client-side filtering (retrieving all items)..."
            $allItems = Get-MgSiteListItem -SiteId $SiteID -ListId $ListID -ExpandProperty Fields -All -ErrorAction Stop
            Write-PSFMessage -Level Verbose -Message "Retrieved $($allItems.Count) total items for client-side filtering"
            
            # Filter client-side for upcoming week
            $filteredItems = $allItems | Where-Object {
                $fieldValue = $_.Fields.AdditionalProperties[$DateFieldName]
                if ($fieldValue) {
                    try {
                        $itemDate = [datetime]$fieldValue
                        # Check if event falls within the upcoming week (StartDate to EndDate)
                        return ($itemDate -ge $StartDate -and $itemDate -le $EndDate)
                    }
                    catch {
                        Write-PSFMessage -Level Debug -Message "Could not parse date from field '$DateFieldName': $fieldValue"
                        return $false
                    }
                }
                return $false
            }
            
            Write-PSFMessage -Level Verbose -Message "Client-side filtering resulted in $($filteredItems.Count) items"
            return $filteredItems
        }
        else {
            throw "All filtering methods failed and client-side fallback is disabled"
        }
    }
    catch {
        Write-PSFMessage -Level Error -Message "Failed to retrieve SharePoint list items: $_"
        throw
    }
}
