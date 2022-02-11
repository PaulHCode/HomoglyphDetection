function Get-LooksLikeValue {
    [CmdletBinding()]
    [Alias()]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $Text,
        [hashtable]
        $KeyHash = $Script:LooksLikeHash
    )

    Begin {    }
    Process {
        $result = [string]''
        ForEach ($char in ($Text.ToCharArray())) {
            $result += $KeyHash[[char]$char]
        }
        $result
    }
    End {    }
}
