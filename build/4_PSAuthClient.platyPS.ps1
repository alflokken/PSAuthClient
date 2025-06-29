param ( 
    $moduleName = "PSAuthClient",
    [Parameter(Mandatory=$true)]$moduleVersion,
    $basePath = "$PSScriptRoot\.." 
)

# ensure platyPS is present
if ( !(Get-Module -ListAvailable -Name "platyPS") ) { Install-Module platyPS -Repository PSGallery -Force -Scope CurrentUser }
Import-Module platyPS -ErrorAction Stop

# check correct target module version
if ( !(Get-Module -name $moduleName | where { $_.version -eq $moduleVersion}) ) { 
    try { Import-Module "$basePath\release\$moduleName\$moduleVersion\$moduleName.psd1" -Force }
    catch { throw "failed to import module $moduleName version $moduleVersion" }
}

# build doc from comment based help
try { Update-MarkdownHelp "$basePath\docs" -ErrorAction stop }
catch { throw $_ }

# assume undefined markdown code blobs are powershell
get-childitem "$basePath\docs\" -Recurse -Filter *.md | Foreach-Object { 
    
    [array]$content = get-content $_.FullName -Encoding utf8NoBOM
    $inCodeBlock = $false
    
    for ( $i = 0; $i -lt $content.count; $i++ ) { 
        $atEndOfBlob = $false
        if ( $content[$i] -match "^``{3}" -and !$inCodeBlock ) { 
            $inCodeBlock = $true
            if ( $content[$i] -match "^``{3}$" ) {  $content[$i] = $content[$i] -replace "^``{3}$", "``````powershell" }
        }
        elseif ( $content[$i] -match "^``{3}$" ) { $inCodeBlock = $false }
    }
    
    $content | set-content $_.FullName -Encoding utf8NoBOM
}