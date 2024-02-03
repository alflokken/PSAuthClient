param ( $basePath = "$PSScriptRoot\..\" )
if ( !(Test-Path "$basePath\packages\nuget.exe") ) { 
    New-Item -ItemType Directory -Path "$basePath\packages" -Force | Out-Null
    Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe'-OutFile "$basePath\packages\nuget.exe" 
}
Start-Process -FilePath "$basePath\packages\nuget.exe" -ArgumentList "restore $basePath\packages.config -verbosity detailed -configfile $basePath\NuGet.config -outputdirectory $basePath\packages" -Wait -NoNewWindow

foreach ( $package in ([XML](Get-Content "$basePath\packages.config")).packages.package ) { 
    write-debug $package.id
    New-Item -ItemType Directory -Path "$basePath\release\$($package.id).$($package.version)" -Force | Out-Null
    foreach ( $framework in (Get-ChildItem "$basePath\packages\$($package.id).$($package.version)\lib" -Directory) ) { 
        write-debug $framework
        copy-item -Recurse -Path $framework.FullName -Destination "$basePath\release\$($package.id).$($package.version)" -Force
        if ( $package.id -eq "Microsoft.Web.WebView2") {
            Get-ChildItem -Recurse -path "$basePath\packages\$($package.id).$($package.version)\runtimes\win-x64\native\" | copy-item -Destination "$basePath\release\$($package.id).$($package.version)\$($framework.Name)\" -Force 
        }
    }
}