
Function Get-ValuesFromPS {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -PathType Leaf $_ })]
        $FileName
    )

    $foundFunctions = @()
    $foundVariables = @()

    $file = (Get-Item $FileName).FullName
    $AST = [System.Management.Automation.Language.Parser]::ParseFile(
        $file,
        [ref]$null,
        [ref]$Null
    )
    
    $FunctionsInThisFile = ForEach ($Function in ($AST.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true))) {
        Get-ValueReport -Name ($Function.Extent.Text.Split("`n")[0].split(' ')[1].split('{')[0].split('(')[0]).Replace("$([char]13)", '') -Type 'Function' -File $file
    }
    $foundFunctions += $FunctionsInThisFile | Group-Object Name, Type, File | ForEach-Object { $_.Group | Select-Object * -First 1 }


    $VariablesInThisFile = ForEach ($Variable in ($AST.FindAll({ $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] }, $true))) {
        If (<#$Variable.Extent.Text -notin $automaticVariables -and #>$Variable.Extent.Text -notlike "`$env:*") {
            Get-ValueReport -Name $Variable.Extent.Text -Type 'Variable' -File $file
        }
    }
    $foundVariables += $VariablesInThisFile |  Group-Object Name, Type, File | ForEach-Object { $_.Group | Select-Object * -First 1 }

    [array]$foundFunctions
    [array]$foundVariables
    #}
}
