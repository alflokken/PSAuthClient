function Clear-WebView2Cache {
    <#
    .SYNOPSIS
    Deletes the WebView2 cache folder.
    .DESCRIPTION
    Removes PSAuthClient WebView2 user data folder (UDF) which is used to store browser data such as cookies, permissions and cached resources.
    .EXAMPLE
    Clear-WebView2Cache
    Deletes the WebView2 cache folder.
    #>
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]param()
    if ($PSCmdlet.ShouldProcess("PSAuthClientWebview2Cache", "delete")) { 
        if ( (test-path "$env:temp\PSAuthClientWebview2Cache\") ) { Remove-Item "$env:temp\PSAuthClientWebview2Cache\" -Recurse -Force }
    }
}