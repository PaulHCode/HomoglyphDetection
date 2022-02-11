Function Split-ByParseElements {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $Text,
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string[]]
        $ParseElements
    )

    $result = $Text
    ForEach ($ParseElement in $ParseElements) {
        $result = ForEach ($item in $result) {
            $item.Split($ParseElement)
        }
    }
    $result | Where-Object { $Null -ne $_ -and '' -ne $_ }
}
