function Test-JsonWebTokenSignature {
    <#
    .SYNOPSIS
    Test the signature of a JSON Web Token (JWT)

    .DESCRIPTION
    Automatically attempt to test the signature of a JSON Web Token (JWT) by using the issuer discovery metadata to get the signing certificate if no signing certificate or secret was provided.

    .PARAMETER jwtInput
    The JSON Web Token (string) to be must be in the form of a valid JWT.

    .PARAMETER SigningCertificate
    X509Certificate2 object to be used for RSA signature verification.

    .PARAMETER client_secret
    Client secret to be used for HMAC signature verification.

    .EXAMPLE
    PS> Test-JsonWebTokenSignature -jwtInput $jwt

    Decodes the JWT and attempts to verify the signature using the issuer discovery metadata to get the signing certificate if no signing certificate or secret was provided.

    .EXAMPLE
    PS> Test-JsonWebTokenSignature -jwtInput $jwt -SigningCertificate $cert

    Decodes the JWT and attempts to verify the signature using the provided certificate.

    .EXAMPLE
    PS> Test-JsonWebTokenSignature -jwtInput $jwt -client_secret $secret

    Decodes the JWT and attempts to verify the signature using the provided client secret.

    #>
    [OutputType([bool])]
    [cmdletbinding(DefaultParameterSetName='certificate')]
    param ( 
        [Parameter( Position = 0, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='certificate')]
        [Parameter( Position = 0, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='client_secret')]
        [ValidatePattern("^e[yJ|w0]([a-zA-Z0-9_-]+[.]){2}", Options = "None")]
        $jwtInput,

        [Parameter(Mandatory = $false, ParameterSetName='certificate')]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$SigningCertificate,

        [Parameter(Mandatory = $true, ParameterSetName='client_secret')]
        $client_secret
    )

    try { $decodedJwt = ConvertFrom-JsonWebToken $jwtInput }
    catch { throw $_ }
    
    # attempt to get signing key from discovery metadata if not specified
    if ( !$signingCertificate -and !$client_secret ) { 
        try {
            Write-Verbose "Test-JWTSignature: Attempting to get signing key from issuer discovery metadata"
            $signingKey = (Invoke-RestMethod -uri (get-oidcDiscoveryMetadata $decodedJwt.iss).jwks_uri -Verbose:$false).keys | Where-Object kid -eq $decodedJwt.header.kid
            if ( !$signingKey ) { throw "Test-JWTSignature: Unable to get signing key from issuer discovery metadata, please specify certificate in input parameter." }
            $signingCertificate = [Security.Cryptography.X509Certificates.X509Certificate2]::new( [convert]::FromBase64String( $signingKey.x5c ) )
            Write-Verbose "Test-JWTSignature: Retrieved keyId $($signingKey.kid) from issuer $($decodedJwt.iss)"
        } 
        catch { throw $_ }
    }

    # data to be verified
    $data = [System.Text.Encoding]::UTF8.GetBytes( ($jwtInput -split "[.]")[0..1] -join "." ) # (YES, DOT-included ,_. ffs.)

    if ( $SigningCertificate ) { 
        # public key
        if ( $decodedJwt.header.alg -match "^[RS|PS]" ) { 
            $publicKey = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPublicKey($signingCertificate) 
            if ( $decodedJwt.header.alg -match "^PS" ) { $padding = [Security.Cryptography.RSASignaturePadding]::Pss }
            else { $padding = [Security.Cryptography.RSASignaturePadding]::Pkcs1 }
        }
        elseif ( $decodedJwt.header.alg -match "^ES" ) { $publicKey = [System.Security.Cryptography.X509Certificates.ECDsaCertificateExtensions]::GetECDsaPublicKey($signingCertificate) }
        else { throw "Test-JWTSignature: Unsupported algorithm $($decodedJwt.header.alg)" } # https://www.iana.org/assignments/jose/jose.xhtml#IESG

        # signature
        [byte[]]$sig = ConvertFrom-Base64UrlEncoding $decodedJwt.signature -rawBytes

        # alg
        $alg = "SHA$(($decodedJwt.header.alg -replace '[a-z]'))"
        Write-Verbose "Test-JWTSignature: attempting to verify $($decodedJwt.header.alg) signature"
        if ( $padding ) { [bool]$response = $publicKey.VerifyData( $data, $sig, $alg, [Security.Cryptography.RSASignaturePadding]::Pkcs1) }
        else { [bool]$response = $publicKey.VerifyData( $data, $sig, $alg ) }
    }
    elseif ( $client_secret ) {
        Write-Verbose "Test-JWTSignature: attempting to verify HMAC signature"
        $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
        $hmacsha.key = [Text.Encoding]::UTF8.GetBytes($client_secret)
        $signature = $hmacsha.ComputeHash($data)
        $signature = convertTo-Base64urlencoding ( [Convert]::ToBase64String($signature) )
        if ( $signature -eq $decodedJwt.signature ) { $response = $true }
        else { $response = $false }
    }
    return $response
}