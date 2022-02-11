#Lists the download URL for every file - includes the AccessToken if specified
Function Get-GitHubContentRecursively {
    [CmdletBinding()]
    param(
        [string]$OwnerName,
        [string]$RepositoryName,
        [string]$Path = $Null,
        [string]$AccessToken
    )
    write-verbose "Working on Owner=$OwnerName Repository=$RepositoryName Path=$Path"
    $result = @()
    $temp = (get-githubcontent -OwnerName $OwnerName -RepositoryName $RepositoryName -Path:$Path -AccessToken:$AccessToken).entries
    $result += ($temp | Where-Object { $_.type -eq 'file' }) | ForEach-Object {
        If ($AccessToken) {
            $("https://$AccessToken@" + $_.download_url.split('https://')[1]) 
        }
        Else {
            $_.download_url
        }
    }
    $result += $temp | Where-Object { $_.type -eq 'dir' } | ForEach-Object { Get-GitHubContentRecursively -OwnerName $OwnerName -RepositoryName $RepositoryName -Path $($Path + '/' + $_.Name) }
    $result
}
