if ( $PSVersionTable.PSEdition -eq "Core" ) { $framework = "netcoreapp3.0" }
else { $framework = "net45" }

Join-Path $PSScriptRoot "Microsoft.Web.WebView2.*\$framework\Microsoft.Web.WebView2.*.dll" -Resolve | ForEach-Object {
    Import-Module $_ -ErrorAction Stop
    write-debug "imported assembly $_"
}