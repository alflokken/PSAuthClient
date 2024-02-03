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
    $response = New-Object -TypeName PSObject
    [pscustomobject]$jwt = $jwtInput -split "[.]"
    for ( $i = 0; $i -lt $jwt.count; $i++ ) {
        try { $data = ConvertFrom-Base64UrlEncoding $jwt[$i] | ConvertFrom-Json }
        catch { $data = $jwt[$i] }
        switch ( $i ) {
            0 { $response | Add-Member -NotePropertyName header -TypeName NoteProperty $data }
            1 { $response | Add-Member -NotePropertyName payload -TypeName NoteProperty $data  }
            2 { $response | Add-Member -NotePropertyName signature -TypeName NoteProperty $data  }
        }
    }
    # ...We prefer ordered output
    return $response | Select-Object header, signature -ExpandProperty payload | Select-Object header, * -ErrorAction SilentlyContinue
}