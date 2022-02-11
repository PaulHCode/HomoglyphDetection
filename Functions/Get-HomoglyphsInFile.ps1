<#
.Synopsis
   Gets homoglyphs in the specified file
.DESCRIPTION
   Gets homoglyphs in the specified file. The user must specify how to parse the file using parse elements, regular expressions, or pre-defined methods. 
.EXAMPLE
   Get-HomoglyphsInFile -File .\testfile.txt -ParseElements @(' ', '.', '(', ')', '{', '}', ';', '?', '\', '/', '&', '%', '!', '<<', '>>',"`n")

    The text in testfile.txt is split into words based on the parse elements defined. 
.EXAMPLE
   Get-HomoglyphsInFile -FileName .\testTextFile.txt -Regex "[a-z]+" -RemoveUninteresting

   Name    OCRValue Type         File
    ----    -------- ----        ----
    123     123      customRegex .\testTextFile.txt
    123…    123      customRegex .\testTextFile.txt
    １23    123      customRegex .\testTextFile.txt

    Found all the number values that were separated by text that were homoglyphs
.EXAMPLE
    Get-HomoglyphsInFile -File .\testfile.txt -ParseElements @(' ','.',',',"`n") -RemoveUninteresting
    
    Scans a typical text file for homoglyphs
.EXAMPLE
    ls testfi*.ps1 | Get-HomoglyphsInFile  -Predefined PowerShell -RemoveUninteresting

    Get all files like testfi*.ps1 and remove any homoglyphs across all matching files
.EXAMPLE
    $results = ls testfi*.ps1 | %{Get-HomoglyphsInFile $_  -Predefined PowerShell -RemoveUninteresting}
    $results.name | group | select count,name

    Get all files like test*.ps1 and remove homoglyphs. Group them to show which items were found, and what they're homoglyphs of and how many of each are found.
.EXAMPLE
    $results = @()
    $count = 0
    $files = gci C:\myFolder\ -Recurse -Include "*.ps1" -File
    ForEach($file in $files){
        Write-Progress -PercentComplete ($count/$($files.count)*100) -Activity 'Scanning Files' -CurrentOperation "($count/$($files.count)) - $($file.FullName)"
        $results += Get-HomoglyphsInFile -FullName $file.FullName -Predefined PowerShell
        $count++
    }
    $refinedResults = $refinedResults -Array $results

    Searches all files in C:\myFolder - This is about 130 times faster than scanning the same repo with Find-HomoglyphsInRepo
.PARAMETER FileName
   The path and name of the file to scan for homoglyphs.
.PARAMETER ParseElements
    An array of seperator strings to use to define how to split the text file into words for comparison. Elements can be multiple characters long.
.PARAMETER Regex
    A regular expression defining how to split the text file into words for comparison.
.PARAMETER RemoveUninteresting
   Compares all words in all files analyzed then removes those that are not homoglyphs of another value
.PARAMETER Predefined
    Use one of the predefined parsing criteria
.Link
    https://github.com/paulhcode
#>
Function Get-HomoglyphsInFile {
    [CmdletBinding(DefaultParameterSetName = 'Predefined')]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'ParseElement')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'Regex')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'Predefined')]
        [string]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -PathType Leaf $_ })]
        $FullName,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1, ParameterSetName = 'ParseElement')]
        [string[]]
        $ParseElements, #maybe something like: @(' ', '.', '(', ')', '{', '}', ';', '?', '\', '/', '&', '%', '!', '<<', '>>',"`n")
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1, ParameterSetName = 'Regex')]
        [string]
        $Regex,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'Predefined')]
        [ValidateSet('PowerShell', 'Text')]
        [string]
        $Predefined,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ParseElement')]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Regex')]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Predefined')]
        [switch]
        $RemoveUninteresting
    )
    begin {
        $foundWords = @()
    }
    process {
        #Get the file and split it
        If ($Predefined) {
            switch ($Predefined) {
                'PowerShell' {   
                    $NeedsAnalysis = $false
                    #                    $foundWords = @()
                    $foundWords += Get-ValuesFromPS -FileName $FullName
                }
                'Text' {
                    $NeedsAnalysis = $true
                    $ParseElements = @(' ', '.', "`n", '(', ')')
                }
            }
        }

        If ($ParseElements) {
            $items = Split-ByParseElements -Text (Get-Content $FullName -Raw) -ParseElements $ParseElements
            $type = 'customParse'
        }
        ElseIf ($Regex) {
            $items = [regex]::Split((Get-Content $FullName -Raw), $Regex) | Where-Object { $Null -ne $_ -and '' -ne $_ }
            $type = 'customRegex'
        }
        

        #Analyze it
        If (!$Predefined -or $NeedsAnalysis) {
            $WordsInThisFile = $items | ForEach-Object { Get-ValueReport -Name $_ -Type $type -File $FullName }
            $foundWords += $WordsInThisFile | Group-Object Name, Type, File | ForEach-Object { $_.Group | Select-Object * -First 1 }
        }
        
    }
    end {
        If ($RemoveUninteresting) { Remove-Uninteresting -Array $foundWords }
        Else { $foundWords }
    }
}
