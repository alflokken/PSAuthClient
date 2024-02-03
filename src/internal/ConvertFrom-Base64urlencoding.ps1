function ConvertFrom-Base64UrlEncoding {
    <#
    .SYNOPSIS
    Convert a a base64url string to text.
    .DESCRIPTION
    Base64-URL-encoding is a minor variation on the typical Base64 encoding method, but uses URL-safe characters instead. 
    .PARAMETER value
    The base64url encoded string to convert.
    .PARAMETER rawBytes
    Return output as byteArray instead of the string.
    .EXAMPLE
    ConvertFrom-Base64UrlEncoding -value "eyJ0eXAiOiJKV1QiLCJhbGciOiJ..."
    {"typ":"JWT","alg":"RS256","kid":"kWbkha6qs8wsTnBwiNYOhHbnAw"}
    #>
    param( 
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$value, 
        [Parameter (Mandatory = $false)]
        [switch]$rawBytes 
    )
    # change - back to +, and _ back to /
    $value = $value -replace "-","+" -replace "_","/"
    # determine padding
    switch ( $value.Length % 4 ) {
        0 { break }
        2 { $value += '==' }
        3 { $value += '=' }
    }
    try { 
        $byteArray = [system.convert]::FromBase64String($value)
        if ( $rawBytes ) { return $byteArray }
        else { return [System.Text.Encoding]::Default.GetString($byteArray) }
    }
    catch { throw $_ }
}