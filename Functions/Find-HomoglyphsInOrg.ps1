<#
.Synopsis
    Scans the specified org's repos for homoglyphs
.DESCRIPTION
    Scans the specified org's repos for homoglyphs. The user must specify which file types, how to parse the file using parse elements, regular expressions, or pre-defined methods. 
    Find-HomoglyphsInOrg is slow. I wrote it for fun, not for practicality. Use Get-HomoglyphsInFile on local files for ~100x faster procesing. 
.EXAMPLE
    Find-HomoglyphsInOrg -OwnerName paulhcode
.PARAMETER OwnerName
    The name of the GitHub repository owner to scan
.PARAMETER FileType
    Specify a subset of files to scan, for example "*.ps1" 
.PARAMETER TempDir
    A temporary directory to download files to for processing
.PARAMETER RemoveUninteresting
    Removes any items that are not homoglyphs of other items in the data processed
.Link
    https://github.com/paulhcode
#>
Function Find-HomoglyphsInOrg {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [string]
        $OwnerName, #= "PowerShell"
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 1)]
        [string]
        $FileType = '*',
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
        [string]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        $TempDir,
        [switch]
        $RemoveUninteresting
    )

    $repos = Get-GitHubRepository -OwnerName $OwnerName
    $OrgValues = @()
    $count = 0
    ForEach ($repo in $repos) {
        Write-Progress -Activity "Scanning $count of $($repos.count) repos" -PercentComplete $($count / $($repos.count) * 100) -Id 0 -CurrentOperation $($repo.Full_Name)
        $OrgValues += Find-HomoglyphsInRepo -OwnerName $OwnerName -RepositoryName $($repo.Name) -FileType $FileType -TempDir $TempDir
    }

    If ($RemoveUninteresting) { Remove-Uninteresting $OrgValues }
    Else { $OrgValues }

}
