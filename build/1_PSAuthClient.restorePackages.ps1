param ( 
    $moduleName = "PSAuthClient",
    [Parameter(Mandatory=$true)]$moduleVersion,
    $basePath = "$PSScriptRoot\.."
)

# ensure nuget.exe is available in packages directory
if ( !(Test-Path "$basePath\packages\nuget.exe") ) { 
    New-Item -ItemType Directory -Path "$basePath\packages" -Force | Out-Null
    Start-BitsTransfer 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe'-Destination "$basePath\packages\nuget.exe" 
}

# Restore NuGet packages
Start-Process -FilePath "$basePath\packages\nuget.exe" -ArgumentList "restore `"$basePath\packages.config`" -verbosity detailed -configfile `"$basePath\NuGet.config`" -outputdirectory `"$basePath\packages`"" -Wait -NoNewWindow

# Ensure the release directory exists
$releasePath ="$basePath\release\$moduleName\$moduleVersion"
if ( !(test-path $releasePath) ) { New-Item -ItemType Directory -Path $releasePath -Force | Out-Null }

# Identify WebView2 version from packages.config
$webView2Version = ( ([xml](Get-Content "$basePath\packages.config")).packages.package | where { $_.id -eq "Microsoft.Web.WebView2" } ).version
if ( -not $webView2Version ) { throw "WebView2 package not found in packages.config. Please ensure it is included." }
if ( $webView2Version.count -gt 1 ) { throw "Multiple WebView2 versions found in packages.config." }

# Bundle WebView2 assemblies/runtime to module release directory.
New-Item -ItemType Directory -Path "$releasePath\Microsoft.Web.WebView2.$webView2Version" -Force | Out-Null
# framework specific files
copy-item -Recurse -Path "$basePath\packages\Microsoft.Web.WebView2.$webView2Version\lib\net462" -Destination "$releasePath\Microsoft.Web.WebView2.$webView2Version" -Force
copy-item -Recurse -Path "$basePath\packages\Microsoft.Web.WebView2.$webView2Version\lib_manual\netcoreapp3.0" -Destination "$releasePath\Microsoft.Web.WebView2.$webView2Version" -Force
# runtime specific files
foreach ( $runtime in (Get-ChildItem "$basePath\packages\Microsoft.Web.WebView2.$webView2Version\runtimes" -Directory) ) { 
    copy-item -Recurse -Path "$runtime\native\" -Destination "$releasePath\Microsoft.Web.WebView2.$webView2Version\runtimes\$($runtime.name)\" -Force
}