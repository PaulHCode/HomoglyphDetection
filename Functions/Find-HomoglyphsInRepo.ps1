<#
.Synopsis
    Scans the specified repo for homoglyphs
.DESCRIPTION
    Scans the specified repo for homoglyphs. Find-HomoglyphsInRepo is slow. I wrote it for fun, not for practicality. Use Get-HomoglyphsInFile after downloading the files locally for faster procesing.
.EXAMPLE
    Find-HomoglyphsInRepo -OwnerName azure -RepositoryName azure-powershell -FileType "*.PS1" -TempDir C:\temp -Predefined PowerShell

    Gets all values as parsed by PowerShell AST
.EXAMPLE
    $results = Find-HomoglyphsInRepo -OwnerName paulhcode -RepositoryName RecurringADChecks -TempDir C:\temp\ -Predefined PowerShell
    Remove-Uninteresting $results

    Finds all items of interest in the repo then finds the homoglyphs
.PARAMETER OwnerName
    The name of the owner of the GitHub repository to scan
.PARAMETER RepositoryName
    The name of the GitHub repository to scan
.PARAMETER FileType
    Specify a subset of files to scan, for example "*.ps1" 
.PARAMETER TempDir
    A temporary directory to download files to for processing
.PARAMETER AccessToken
    GitHub access token, specify it to decrease throttling by GitHub
.PARAMETER RemoveUninteresting
    Removes any items that are not homoglyphs of other items in the data processed
.Link
    https://github.com/paulhcode
#>
Function Find-HomoglyphsInRepo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $OwnerName, #= "PowerShell"
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string]
        $RepositoryName,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [string]
        $FileType = '*',
        [ValidateSet('PowerShell', 'Text')]
        [string]
        $Predefined,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [string]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        $TempDir,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 4)]
        [string]
        [ValidateScript({ $_.Length -eq 40 })]
        $AccessToken,
        [switch]
        $RemoveUninteresting
    )
 
    If ($AccessToken) {
        $ListOfFiles = Get-GitHubContentRecursively -OwnerName $OwnerName -RepositoryName $RepositoryName -AccessToken:$AccessToken
    }
    Else {
        $ListOfFiles = Get-GitHubContentRecursively -OwnerName $OwnerName -RepositoryName $RepositoryName
    }

    #    write-verbose "List of files = $ListofFiles"

    #scan the files in the org
    $RepoValues = @()
    $count = 0
#    If (!(Test-Path $TempDir)) { mkdir $TempDir }
    ForEach ($file in $ListOfFiles) {
        Write-Progress -Activity "Scanning $count of $($ListOfFiles.count) files" -PercentComplete $($count / $($ListOfFiles.count) * 100) -Id 1 -CurrentOperation $($file.html_url)
        $destinationFile = Join-Path $TempDir ((split-path $file -leaf)<#.Replace('.', '')#>) #add back in replace if needed, forgot why i thought it was needed at one point
#               write-verbose "DestinationFile = $destinationFile"
        curl -L -o $destinationFile $file
        #Scan the file
        $RepoValues += Get-HomoglyphsInFile -FullName $destinationFile -Predefined $Predefined #Get-ValuesFromPS -FileName ".\$($file.name)" #I should include a way to include additional metadata like the HTMLURL for the file to make it easier to find later
#                write-verbose "Removing $destinationFile"
        Remove-Item $destinationFile
        #If it is sketchy, then keep it
        $count++
    }

    If ($RemoveUninteresting) { Remove-Uninteresting $RepoValues }
    Else { $RepoValues }

}

