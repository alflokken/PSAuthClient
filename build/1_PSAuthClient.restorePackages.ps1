param ( $basePath = "$PSScriptRoot\..\" )
if ( !(Test-Path "$basePath\packages\nuget.exe") ) { 
    New-Item -ItemType Directory -Path "$basePath\packages" -Force | Out-Null
    Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe'-OutFile "$basePath\packages\nuget.exe" 
}
Start-Process -FilePath "$basePath\packages\nuget.exe" -ArgumentList "restore $basePath\packages.config -verbosity detailed -configfile $basePath\NuGet.config -outputdirectory $basePath\packages" -Wait -NoNewWindow