param ( 
    $moduleName = "PSAuthClient",
    [Parameter(Mandatory=$true)]$moduleVersion,
    $basePath = "$PSScriptRoot\..",
    $configFile = "$PSScriptRoot\..\tests\config.json"  
)
# remove modules and dot Sourced functions 
Get-Module | ? Author -Match "^Alf Løkken" | Remove-Module
if ( !(Get-Command "Remove-PsSessionData" -ErrorAction SilentlyContinue) ) { 
    $scriptblock = Invoke-RestMethod "https://gist.githubusercontent.com/alflokken/0dfe4111b813f989469636fec536bca4/raw/d1c0d47f22690de7436ff73ddb2f1f98ff0a24b9/Remove-PsSessionData.ps1"
    Invoke-Expression $scriptblock
} else { Remove-PsSessionData -removeDotSourcedFunctions }

# output the current psversion, we want perform test on both v5 & v7
write-host -f c "PowerShell version: $($PSVersionTable["PSVersion"].ToString())"

# check if pester v5+ is installed, else install it
if ( !(Get-Module Pester -ListAvailable | ? Version -Match "^5") ) { Install-Module Pester -MinimumVersion "5.0.0" -Repository PSGallery -Force -Scope:CurrentUser }

# import and invoke pester
Import-Module Pester -MinimumVersion "5.0.0" -ErrorAction Stop

$testParams = @{
    moduleName = $moduleName
    moduleVersion = $moduleVersion
    configFile = (get-item $configFile).FullName
}

"$basePath\tests\common.Tests.ps1","$basePath\tests\auth.Tests.ps1" | %{ 
    Invoke-Pester -Container (New-PesterContainer -Path $_ -Data $testParams) -Output Detailed
}