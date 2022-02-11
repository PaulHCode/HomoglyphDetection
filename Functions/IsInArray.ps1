Function IsInArray{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
        [pscustomobject]
        $Value,
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
        [pscustomobject[]]
        $Array,
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=2)]
        [string[]]
        $Properties
    )
    $result = $false
    For($i = 0;$i -lt $Array.Count;$i++){
        If($Null -eq (Compare-Object -ReferenceObject $Value -DifferenceObject $Array[$i] -Property $Properties)){
            $result = $true
            break
        }        
    }
    $result
}
