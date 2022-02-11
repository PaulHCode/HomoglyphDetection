
Function Get-ValueReport{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        [ValidateNotNullOrEmpty()]
        $Name,
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string]
        [ValidateNotNullOrEmpty()]
        $Type,
        [Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        [string]
        [ValidateNotNullOrEmpty()]
        $File
    )

    [pscustomobject]@{
        Name = $Name
        OCRValue = Get-LooksLikeValue -Text $Name
        Type = $Type
        File = $file
    }
}

