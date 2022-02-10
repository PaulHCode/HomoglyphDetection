# Homoglyph Detection

## Overview

This module is comprised of cmdlets to detect homoglyphs in code or other documents.

## Functions
- Get-HomoglyphsInFile - Gets homoglyphs in the specified file. The user must specify how to parse the file using parse elements, regular expressions, or pre-defined methods.
- Remove-Uninteresting - Removes items that are not homoglyphs of other items in the list
- Find-HomoglyphsInRepo - Scans the specified repo for homoglyphs
- Find-HomoglyphsInOrg - Scans the specified org's repos for homoglyphs

## Examples
```PowerShell
   Get-HomoglyphsInFile -FileName .\testTextFile.txt -Regex "[a-z]+" -RemoveUninteresting

   Name    OCRValue Type         File
    ----    -------- ----        ----
    123     123      customRegex .\testTextFile.txt
    123…    123      customRegex .\testTextFile.txt
    １23    123      customRegex .\testTextFile.txt

    #Found all the number values that were separated by text that were homoglyphs


    Get-HomoglyphsInFile -File .\testfile.txt -ParseElements @(' ','.',',',"`n") -RemoveUninteresting
    
    #Scans a typical text file for homoglyphs


    ls testfi*.ps1 | Get-HomoglyphsInFile  -Predefined PowerShell -RemoveUninteresting

    #Get all files like testfi*.ps1 and remove any homoglyphs across all matching files


    $results = ls testfi*.ps1 | %{Get-HomoglyphsInFile $_  -Predefined PowerShell -RemoveUninteresting}
    $results.name | group | select count,name

    #Get all files like test*.ps1 and remove homoglyphs. Group them to show which items were found, and what they're homoglyphs of and how many of each are found.


    $results = @()
    $count = 0
    $files = gci C:\myFolder\ -Recurse -Include "*.ps1" -File
    ForEach($file in $files){
        Write-Progress -PercentComplete ($count/$($files.count)*100) -Activity 'Scanning Files' -CurrentOperation "($count/$($files.count)) - $($file.FullName)"
        $results += Get-HomoglyphsInFile -FullName $file.FullName -Predefined PowerShell
        $count++
    }
    $refinedResults = $refinedResults -Array $results

    #Searches all files in C:\myFolder - This is about 130 times faster than scanning the same repo with Find-HomoglyphsInRepo
```

