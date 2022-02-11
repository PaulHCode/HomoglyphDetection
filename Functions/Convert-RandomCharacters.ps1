<#
.Synopsis
    Replaces characters in the InputString with similar looking characters
.DESCRIPTION
    Replaces characters in the InputString with similar looking characters
.EXAMPLE
    Convert-RandomCharacters -InputString "Hello" -PercentOfChange 50
.EXAMPLE
    $result = Convert-RandomCharacters -InputString "Hello world!" -PercentChanceOfChange 50

    $result.ToCharArray() | %{$_ + " - " + [int][char]$_}
    Н - 1053
    е - 1077
    l - 108
    ⅼ - 8572
    о - 1086
    - 32
    ѡ - 1121
    о - 1086
    r - 114
    ⅼ - 8572
    ԁ - 1281
    ! - 33
.PARAMETER InputString
    String to convert random characters in
.PARAMETER PercentChanceOfChange
    Chance of changing each character that has an alternate value defined in KeySet to an alternate value
.PARAMETER KeySet
    A hashtable defining alternate values for the characters. It changes from latin characters to cyrillic by default.
.Link
    https://github.com/paulhcode
#>
function Convert-RandomCharacters {
    [CmdletBinding()]
    param(
        [string]$InputString,
        [float]$PercentChanceOfChange = 5,
        [hashtable]$KeySet = $Script:KeyLatin_Cyrillic
    )
    $result = ForEach ($char in $InputString.ToCharArray()) {
        #        write-verbose "converting $chcar ($([int]$char))"
        If ($char -in ($KeySet.Keys)) {
            #            write-verbose "$char found in KeySet"
            If ($PercentChanceOfChange -ge (Get-Random -Minimum 0 -Maximum 100)) {
                #                write-verbose "replacing $char with $($KeySet[[string]$char])"
                $KeySet[[string]$char]
            }
            Else {
                #                write-verbose "keeping $char"
                $char
            }
        }
        Else {
            #            write-verbose "$char not in KeySet"
            $char
        }        
    }
    -join $result
}
