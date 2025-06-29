param ( 
    $moduleName = "PSAuthClient",
    [Parameter(Mandatory=$true)]$moduleVersion,
    $prerelease = $false,
    $basePath = "$PSScriptRoot\.."
)
$releasePath ="$basePath\release\$moduleName\$moduleVersion"

# source files to be included in the module
$filesToRollup = (Get-ChildItem "$basePath\src" -File -Recurse -Filter "*.ps1" | Where-Object { $_.FullName -notmatch "\\((module(s)?)|script(s)?)\\" }).fullname | sort -Unique

# placeholders
$cmdletsToExport = @(); $aliasesToExport = @(); $contentArray = @()

# process source file content
foreach ( $file in $filesToRollup ) { 
    $content = get-content $file -Encoding utf8
    $contentArray += $content
    # public functions are exported
    if ( $file -notmatch "\\src\\internal\\" ) { 
        # functions
        $cmdletsToExport += $content | where { $_ -match "^function\s{1}" } 
        # extract aliases
        $aliasesToExport += $content | where { $_ -match "\[Alias\(" -and $_ -notmatch "^#|#\[Alias\(" } 
    }
}

# add contents to the module file
Set-Content -Path "$releasePath\$moduleName.psm1" -Value $contentArray -Debug:$true -Confirm:$false -Force

# scripts to include
$scriptList = Get-ChildItem "$basePath\src\scripts" -File -Recurse -Filter "*.ps1"
# copy the scripts to the release path
$scriptList | Copy-Item -Destination $releasePath -Force
$scriptList = $scriptlist.FullName -replace ".*\\scripts\\",".\"

# clean up syntax
$cmdletsToExport = $cmdletsToExport -replace "function\s+" -replace "(\s+)?{(\s+)?" | sort
$aliasesToExport = ($aliasesToExport -replace "(\s+)?\[Alias\([('|`")]","" -replace "('|`")" -replace "\)]") -split "," | sort -Unique

# files to include
$fileList = (Get-ChildItem $releasePath -Recurse -File).FullName -replace ".*$moduleName\\$moduleVersion\\"
$fileList += "$moduleName.psd1"
$fileList = $fileList | sort

# build manifest
$moduleManifest = @{ 
    Author = "Alf Løkken"
    RootModule = "$moduleName.psm1"
    Path = "$releasePath\$moduleName.psd1"
    ModuleVersion = $moduleVersion
    PowerShellVersion = "5.1"
    CompatiblePSEditions = @('Desktop', 'Core')
    DotNetFrameworkVersion = "4.5"
    Guid = "a1f1337a-d29e-4ad4-acb7-c39bece2d747"
    Description = "PowerShell Authentication Client (OAuth2.0/OIDC)"
    Copyright = "(c) Alf Løkken. All rights reserved."
    Tags = @("OAuth2.0","OAuth","OIDC","OpenID","OpenIDConnect","Authentication","Authorization","AuthN","AuthZ","PKCE","WebView2","JWT")
    LicenseUri = "https://raw.githubusercontent.com/alflokken/PSAuthClient/main/LICENSE"
    ProjectUri = "https://github.com/alflokken/PSAuthClient"
    CmdletsToExport = $cmdletsToExport
    FunctionsToExport = $cmdletsToExport
    AliasesToExport = $aliasesToExport
    FileList = $fileList
    ScriptsToProcess = $scriptlist
}
if ( $prerelease ) { $moduleManifest.Prerelease = "preview" }
New-ModuleManifest @moduleManifest
return "$modulename-$($moduleversion): $([int]((Get-Item "$releasePath\$moduleName.psm1").Length/1024))kb rolled up to release ($($contentArray.count) lines in $($filesToRollup.count) files with $($cmdletsToExport.Count) functions)"