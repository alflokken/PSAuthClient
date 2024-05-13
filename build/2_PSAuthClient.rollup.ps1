param ( 
    $moduleName = "PSAuthClient",
    [Parameter(Mandatory=$true)]$moduleVersion,
    $prerelease = $false,
    $basePath = "$PSScriptRoot\..\" 
)

$releasePath ="$basePath\release\$moduleName\$moduleVersion"

# dependencies
foreach ( $package in ([XML](Get-Content "$basePath\packages.config")).packages.package ) { 
    write-debug $package.id
    New-Item -ItemType Directory -Path "$releasePath\$($package.id).$($package.version)" -Force | Out-Null
    foreach ( $framework in (Get-ChildItem "$basePath\packages\$($package.id).$($package.version)\lib" -Directory) ) { 
        write-debug $framework
        copy-item -Recurse -Path $framework.FullName -Destination "$releasePath\$($package.id).$($package.version)" -Force
        if ( $package.id -eq "Microsoft.Web.WebView2") {
            Get-ChildItem -Recurse -path "$basePath\packages\$($package.id).$($package.version)\runtimes\win-x64\native\" | copy-item -Destination "$releasePath\$($package.id).$($package.version)\$($framework.Name)\" -Force 
        }
    }
}

if ( !(test-path $releasePath) ) { New-Item -ItemType Directory -Path $releasePath -Force | Out-Null }

$filesToRollup = @()
"$basePath\src\" | %{ $filesToRollup += Get-ChildItem $_ -filter *.ps1 -Recurse | where { $_.FullName -notmatch "\\((module(s)?)|script(s)?)\\" } }
$filesToRollup = ($filesToRollup | sort name).FullName | sort -Unique

$cmdLetBlob = @()
$aliasBlob = @()
$contentArray = @()
foreach ( $file in $filesToRollup ) { 
    $content = get-content $file -Encoding utf8
    $contentArray += $content
    # export public functions
    if ( $file -notmatch "\\src\\internal\\" ) { 
        # function
        $cmdLetBlob += $content | where { $_ -match "^function\s{1}" }
        # export aliases
        $aliasBlob += $content | where { $_ -match "\[Alias\(" -and $_ -notmatch "^#|#\[Alias\(" } 
    }
}

# export module
Set-Content -Path "$releasePath\$moduleName.psm1" -Value $contentArray -Debug:$true -Confirm:$false

# files to include in manifest
$fileList = Get-ChildItem $releasePath -Directory | % { Get-ChildItem -Recurse $_.fullname -File } 

# scripts to process
$scriptList = Get-ChildItem "$basePath\src\scripts" -File -Recurse -Filter "*.ps1"
$scriptList | Copy-Item -Destination $releasePath -Force

# build manifest
$moduleManifest = @{ 
    Author = "Alf Løkken"
    CompanyName = "Intility AS"
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
    CmdletsToExport = ( ($cmdLetBlob -replace "function\s+") -replace "(\s+)?{(\s+)?" | sort ) 
    FunctionsToExport = ( ($cmdLetBlob -replace "function\s+") -replace "(\s+)?{(\s+)?" | sort ) 
    AliasesToExport = (( ( ($aliasBlob -replace "(\s+)?\[Alias\([('|`")]") -replace "('|`")" ) -replace "\)]" ) -split ",")
    FileList = $fileList.FullName -replace ".*$moduleName\\$moduleVersion\\" | sort
    ScriptsToProcess = $scriptlist.FullName -replace ".*\\scripts\\",".\"
}
if ( $prerelease ) { $moduleManifest.Prerelease = "preview" }
New-ModuleManifest @moduleManifest
return "$modulename-$($moduleversion): $([int]((Get-Item "$releasePath\$moduleName.psm1").Length/1024))kb rolled up to release ($($contentArray.count) lines in $($filesToRollup.count) files with $($cmdLetBlob.Count) functions)"