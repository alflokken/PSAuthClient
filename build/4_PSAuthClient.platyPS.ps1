param ( 
    $moduleName = "PSAuthClient",
    [Parameter(Mandatory=$true)]$moduleVersion,
    $basePath = "$PSScriptRoot\..\" 
)

# build doc from comment based help
try { 
    Import-Module "$basePath\release\$moduleName\$moduleVersion\PSAuthClient.psd1" -Force
    #Update-MarkdownHelp "$modulePath\docs" | Out-Null
    Get-ChildItem "$basePath\docs" -Recurse -Filter *.md | remove-item -Force
    new-MarkdownHelp -Module PSAuthClient -OutputFolder "$basePath\docs\" -Debug
}
catch { throw "failed to update markdown documentation" }

# assume undefined markdown code blobs are powershell
get-childitem "$basePath\docs\" -Recurse -Filter *.md | % { 
    [array]$content = get-content $_.FullName -Encoding utf8NoBOM
    $inBlob = $false
    for ( $i = 0; $i -lt $content.count; $i++ ) { 
        $atEndOfBlob = $false
        if ( $content[$i] -match "^``{3}" -and !$inBlob ) { 
            $inBlob = $true
            if ( $content[$i] -match "^``{3}$" ) {  $content[$i] = $content[$i] -replace "^``{3}$", "``````powershell" }
        }
        elseif ( $content[$i] -match "^``{3}$" ) { $inBlob = $false }
    }
    $content | set-content $_.FullName -Encoding utf8NoBOM
}