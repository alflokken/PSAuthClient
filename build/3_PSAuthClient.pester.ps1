param ( $basePath = "$PSScriptRoot\..\" )

# remove modules and dot Sourced functions 
Get-Module | ? Author -Match "^Alf" | Remove-Module
if ( !(Get-Command "Remove-PsSessionData" -ErrorAction SilentlyContinue) ) { 
    $scriptblock = Invoke-RestMethod "https://gist.githubusercontent.com/alflokken/0dfe4111b813f989469636fec536bca4/raw/2b8bd22a646ac83841a87274bbc03483729a39f3/Remove-PsSessionData.ps1"
    Invoke-Expression $scriptblock
} else { Remove-PsSessionData -removeDotSourcedFunctions }

# output psversion, we want to test both v5 & v7
write-host -f c "PowerShell version: $($PSVersionTable["PSVersion"].ToString())"

# import and invoke pester
Import-Module Pester -MinimumVersion "5.0.0"
invoke-Pester -Output Detailed "$basePath\tests\common.Tests.ps1"
invoke-Pester -Output Detailed "$basePath\tests\auth.Tests.ps1"