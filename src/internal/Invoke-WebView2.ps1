function Invoke-WebView2 {
    <#
    .SYNOPSIS
    PowerShell Interactive browser window using WebView2.

    .DESCRIPTION
    Uses WebView2 (a embedded edge browser) to allow embeded web technologies (HTML, CSS and JavaScript).

    .PARAMETER uri
    The URL to browse.

    .PARAMETER UrlCloseConditionRegex
    (optional, default:'error=') - The form will close when the URL matches the regex.

    .PARAMETER failoverToWindowsFormsWebBrowser
    (optional, defalt:true) - If WebView2 fails to initialize, the form will close and the script will continue using Windows.Forms.WebBrowser (IE11).

    .PARAMETER allowSingleSignOnUsingOSPrimaryAccount
    (optional, default:true) Determines whether to enable Single Sign-on with Azure Active Directory (AAD) resources inside WebView using the logged in Windows account.

    .PARAMETER title
    (optional, default:'PowerShell WebView') - Window-title of the form.

    .PARAMETER Width
    (optional, default:600) - Width of the form.

    .PARAMETER Height
    (optional, default:800) - Height of the form.

    .PARAMETER userAgent
    (optional) Only supported for WebView2, will be ignored if failing over to Windows.Forms.WebBrowser.

    .EXAMPLE
    PS> Invoke-WebView2 -uri "https://microsoft.com/devicelogin" -UrlCloseConditionRegex "//appverify$" -title "Device Code Flow" | Out-Null

    Starts a form with a WebView2 control, and navigates to https://microsoft.com/devicelogin. The form will close when the URL matches the regex '//appverify$'.

    #>
    param(
        [parameter(Position = 0, Mandatory = $true, HelpMessage="The URL to browse.")]
        [string]$uri,

        [parameter( Mandatory = $false, HelpMessage="Form close condition by regex (URL)")]
        [string]$UrlCloseConditionRegex = "error=[^&]*",

        [parameter( Mandatory = $false, HelpMessage="WebView2 failover to System.Windows.Forms.WebBrowser (IE11)")]
        [bool]$failoverToWindowsFormsWebBrowser = $true,

        [parameter( Mandatory = $false, HelpMessage="msSingleSignOnOSForPrimaryAccountIsShared")]
        [bool]$allowSingleSignOnUsingOSPrimaryAccount = $true,

        [parameter( Mandatory = $false, HelpMessage="Forms window title")]
        [string]$title = "PowerShell WebView",

        [parameter( Mandatory = $false, HelpMessage="Forms window width")]
        [int]$Width = "600",

        [parameter( Mandatory = $false, HelpMessage="Forms window height")]
        [int]$Height = "800",

        [parameter( Mandatory = $false, HelpMessage="Customize the User-Agent presented in the HTTP Header.")]
        $userAgent
    
    )
    # https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2environmentoptions.allowsinglesignonusingosprimaryaccount?view=webview2-dotnet-1.0.2210.55
    if ( $allowSingleSignOnUsingOSPrimaryAccount ) { $env:WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS = "--enable-features=msSingleSignOnOSForPrimaryAccountIsShared" }
    else { $env:WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS = $null }
    # initialize WebView2
    try { 
        $web = New-Object 'Microsoft.Web.WebView2.WinForms.WebView2'
        $web.CreationProperties = New-Object 'Microsoft.Web.WebView2.WinForms.CoreWebView2CreationProperties'
        $web.CreationProperties.UserDataFolder = "$env:temp\PSAuthClientWebview2Cache\" 
        $web.Dock = "Fill"
        $web.source = $uri
        if ( $userAgent ) { $web.add_CoreWebView2InitializationCompleted({$web.CoreWebView2.Settings.UserAgent = $userAgent}) }
        # close form on completion (match redirectUri) navigation
        $web.Add_SourceChanged( {
            if ( $web.source.AbsoluteUri -match $UrlCloseConditionRegex )  { $Form.close() | Out-Null }
        })
    }
    # if WebView2 fails to initialize, try to use Windows.Forms.WebBrowser
    catch {
        if ( $failoverToWindowsFormsWebBrowser ) { 
            Write-Warning "Failed to initialize WebView2, trying to use Windows.Forms.WebBrowser."
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
            $web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width = $Width; Height = $Height; Url = $uri }
            # Close form on completion (match redirectUri) navigation
            $docCompletedEvent = {
                if ( $web.Url.AbsoluteUri -match $UrlCloseConditionRegex )  { $form.Close() }
            }
            $web.Add_DocumentCompleted($docCompletedEvent)
            $web.ScriptErrorsSuppressed = $true
            $title = $title + " [COMPATABILITY MODE]"
    }
        else { throw $_ }
    }
    # Create form
    $form = New-Object System.Windows.Forms.Form -Property @{Width=$Width;Height=$Height;Text=$title} -ErrorAction Stop
    # Add the WebBrowser control to the form
    $form.Controls.Add($web)
    $form.Add_Shown( { $form.Activate() } )
    $form.ShowDialog() | Out-Null
    $response = $web.Source
    $web.Dispose()
    return $response
}