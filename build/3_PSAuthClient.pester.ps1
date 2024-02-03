param ( $basePath = "$PSScriptRoot\..\" )
if ( !(Get-Command "Remove-PsSessionData" -ErrorAction SilentlyContinue) ) { 
    $scriptblock = Invoke-RestMethod "https://gist.github.com/alflokken/0dfe4111b813f989469636fec536bca4/raw/78b2f3c2a17e7f56b2deae5a9ce1a89e2639baf1/Remove-PsSessionData.ps1"
    Invoke-Expression $scriptblock
} else { Remove-PsSessionData -removeDotSourcedFunctions }
# output psversion, we want to test both v5 & v7
write-host -f c "PowerShell version: $($PSVersionTable["PSVersion"].ToString())"
# remove modules and dot Sourced functions 
Get-Module | ? Author -Match "^Alf" | Remove-Module
# import and invoke pester
Import-Module Pester -MinimumVersion "5.0.0"
invoke-Pester -Output Detailed "$basePath\tests\common.Tests.ps1"
invoke-Pester -Output Detailed "$basePath\tests\auth.Tests.ps1"