<#
.Synopsis
    Removes items that are not homoglyphs of other items in the list
.DESCRIPTION
    Removes items that are not homoglyphs of other items in the list
.EXAMPLE
    $InterestingResults = Remove-Uninteresting $Results
.PARAMETER Array
    The output from Find-HomoglyphsInFile, Find-HomoglyphsInRepo, or Find-HomoglyphsInOrg
.Link
    https://github.com/paulhcode
#>
Function Remove-Uninteresting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [pscustomobject[]]
        $Array
    )

    #removes duplicates that have the same ocrvalue and type but not name and not necessairly file
    $refined = ($Array | Group-Object -Property ocrvalue, type | Where-Object { $_.count -gt 1 }).group
    $ocrGroup = $refined | Group-Object -Property ocrValue
    $nameGroup = $refined | Group-Object -Property Name

    $names = ForEach ($item in $nameGroup) {
        If ($($item.Name) -in $($ocrGroup.Name)) {
            If (($ocrGroup | Where-Object { $_.Name -eq $($item.Name) }).Count -eq $($item.count)) {
                #same number, so not suspicious
            }
            Else {
                $item
            }
        }
    }

    $refined | Where-Object { $_.ocrvalue -in $($names.name) }
}

