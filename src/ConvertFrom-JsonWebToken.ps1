function ConvertFrom-JsonWebToken {
    <#
    .SYNOPSIS
    Convert (decode) a JSON Web Token (JWT) to a PowerShell object.

    .DESCRIPTION
    Convert (decode) a JSON Web Token (JWT) to a PowerShell object.

    .PARAMETER jwtInput
    The JSON Web Token (string) to be must be in the form of a valid JWT.

    .EXAMPLE
    PS> ConvertFrom-JsonWebToken "ew0KICAidHlwIjogIkpXVCIsDQogICJhbGciOiAiUlMyNTYiDQp9.ew0KICAiZXhwIjogMTcwNjc4NDkyOSwNCiAgImVjaG8..."
    header    : @{typ=JWT; alg=RS256}
    exp       : 1706784929
    echo      : Hello World!
    nbf       : 1706784629
    sub       : PSAuthClient
    iss       : https://example.org
    jti       : 27913c80-40d1-46a3-89d5-d3fb9f0d1e4e
    iat       : 1706784629
    aud       : PSAuthClient
    signature : OHIxRGxuaXVLTjh4eXhRZ0VWYmZ3SHNlQ29iOUFBUVRMK1dqWUpWMEVXMD0

    #>
    param ( 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidatePattern("^e[yJ|w0]([a-zA-Z0-9_-]+[.]){2}", Options = "None")]
        [string]$jwtInput
    )

    $segments = $jwtInput -split "[.]"
    if ( $segments.Count -ne 3 ) { throw "Invalid JWT format: Expected 3 segments (header.payload.signature)."}

    $decodedJwt = [pscustomobject]@{
        header    = $null
        payload   = $null
        signature = $segments[2] 
    }

    try { $decodedJwt.header = ConvertFrom-Base64UrlEncoding $segments[0] | ConvertFrom-Json }
    catch {
        write-warning "Failed to decode JWT header. The header will be returned as a Base64Url encoded string."
        $decodedJwt.header = $segments[0]
    }

    try { $decodedJwt.payload = ConvertFrom-Base64UrlEncoding $segments[1] | ConvertFrom-Json }
    catch {
        write-warning "Failed to decode JWT payload. The payload will be returned as a Base64Url encoded string."
        $decodedJwt.payload = $segments[1]
    }

    # ordered output with the payload expanded
    return $decodedJwt | Select-Object header, signature -ExpandProperty payload | Select-Object header, * -ErrorAction SilentlyContinue
}