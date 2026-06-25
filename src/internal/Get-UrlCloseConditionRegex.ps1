function Get-UrlCloseConditionRegex {
    <#
    .SYNOPSIS
    Builds the regex that tells the WebView2 window when an interactive auth request is finished.

    .DESCRIPTION
    Invoke-OAuth2AuthorizationEndpoint passes this pattern to Invoke-WebView2, which closes the
    embedded browser the moment a navigated URL matches it. It's a plain boolean -match: nothing
    downstream reads the capture groups, only match / no-match decides when to close.

    With a redirect_uri, the pattern has two branches:

        ($redirect_uri)?.*(?:code=([^&]+)|error=([^&]+))   # Branch A
        ^($redirect_uri)                                   # Branch B

    Branch A closes on any URL carrying a non-empty code= or error= value. The redirect_uri prefix
    is optional (the trailing '?'), so this branch fires on the response no matter which host
    delivered it. That looseness is deliberate; see the NOTES and the tests for the trade-off.

    Branch B closes when the URL simply starts with the redirect_uri. This is what catches implicit
    and hybrid responses, where the token comes back in the #fragment with no code=/error= in the
    query, as well as a plain landing on the redirect_uri.

    With no redirect_uri the pattern falls back to "(?:code=([^&]+)|error=([^&]+))". An empty
    redirect_uri used to build an invalid pattern starting with '?' (Issue #8); the fallback avoids it.

    .NOTES
    The redirect_uri is run through [regex]::Escape() before it goes into the pattern, so any
    metacharacters it contains (a literal '.', '?', '(' and so on) match literally instead of being
    interpreted. That keeps the pattern compilable for any redirect_uri and stops a stray character
    from changing what matches. See the "Metacharacters in redirect_uri (regex-escaped)" and
    "compiles safely (Issue #8 class)" tests.

    .PARAMETER redirect_uri
    The client callback URI from the authorization request. Optional; empty or $null selects the fallback pattern.

    .EXAMPLE
    PS> Get-UrlCloseConditionRegex -redirect_uri "http://localhost"
    (http://localhost)?.*(?:code=([^&]+)|error=([^&]+))|^(http://localhost)

    .EXAMPLE
    PS> Get-UrlCloseConditionRegex -redirect_uri "https://app.contoso.com/cb"
    (https://app\.contoso\.com/cb)?.*(?:code=([^&]+)|error=([^&]+))|^(https://app\.contoso\.com/cb)

    .EXAMPLE
    PS> Get-UrlCloseConditionRegex
    (?:code=([^&]+)|error=([^&]+))
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [parameter( Position = 0, Mandatory = $false )]
        [AllowEmptyString()]
        [AllowNull()]
        [string]$redirect_uri
    )
    if ( $redirect_uri ) { 
        $escaped = [regex]::Escape($redirect_uri)
        return "($escaped)?.*(?:code=([^&]+)|error=([^&]+))|^($escaped)"
    }
    else { return "(?:code=([^&]+)|error=([^&]+))" }
}