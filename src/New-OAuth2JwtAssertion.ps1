function New-Oauth2JwtAssertion {
    <#
    .SYNOPSIS
    Create a JWT Assertion for OAuth2.0 Client Authentication.
    
    .DESCRIPTION
    Create a JWT Assertion for OAuth2.0 Client Authentication.

    .PARAMETER issuer
    iss, must contain the client_id of the OAuth Client.

    .PARAMETER subject
    sub, must contain the client_id of the OAuth Client.

    .PARAMETER audience
    aud, should be the URL of the Authorization Server's Token Endpoint.

    .PARAMETER jwtId
    jti, unique token identifier. Random GUID by default.

    .PARAMETER customClaims
    Hashtable with custom claims to be added to the JWT payload (assertion).

    .PARAMETER client_certificate
    Location Cert:\CurrentUser\My\THUMBPRINT, x509certificate2 or RSA Private key.

    .PARAMETER key_id
    kid, key identifier for assertion header

    .PARAMETER client_secret
    clientsecret for HMAC signature

    .EXAMPLE
    PS> New-Oauth2JwtAssertion -issuer $client_id -subject $client_id -audience $oidcDiscoveryMetadata.token_endpoint -client_certificate $cert

    client_assertion_jwt          ew0KICAidHlwIjogIkpXVCIsDQogICJhbGciOiAiUlMyNTYiDQp9.ew0KICAia...
    client_assertion_type          urn:ietf:params:oauth:client-assertion-type:jwt-bearer
    header                         @{typ=JWT; alg=RS256}
    payload                        @{iss=PSAuthClient; nbf=1706785754; iat=1706785754; sub=PSAu...}

    #>
    [cmdletbinding(DefaultParameterSetName='private_key_jwt')]
    param(
        [parameter( Position = 0, Mandatory = $true, ParameterSetName='private_key_jwt', HelpMessage="iss, must contain the client_id of the OAuth Client.")]
        [parameter( Position = 0, Mandatory = $true, ParameterSetName='client_secret_jwt', HelpMessage="iss, must contain the client_id of the OAuth Client.")]
        [string]$issuer,

        [parameter( Position = 1, Mandatory = $true, ParameterSetName='private_key_jwt', HelpMessage="sub, must contain the client_id of the OAuth Client.")]
        [parameter( Position = 1, Mandatory = $true, ParameterSetName='client_secret_jwt', HelpMessage="sub, must contain the client_id of the OAuth Client.")]
        [string]$subject,

        [parameter( Position = 2, Mandatory = $true, ParameterSetName='private_key_jwt', HelpMessage="aud, should be the URL of the Authorization Server's Token Endpoint.")]
        [parameter( Position = 2, Mandatory = $true, ParameterSetName='client_secret_jwt', HelpMessage="aud, should be the URL of the Authorization Server's Token Endpoint.")]
        [string]$audience,

        [parameter( Position = 3, Mandatory = $false, ParameterSetName='private_key_jwt', HelpMessage="jti, unique token identifier.")]
        [parameter( Position = 3, Mandatory = $false, ParameterSetName='client_secret_jwt', HelpMessage="jti, unique token identifier.")]
        [string]$jwtId = [string]([guid]::NewGuid()),

        [parameter( Mandatory = $false, ParameterSetName='private_key_jwt', HelpMessage="Hashtable with custom claims.")]
        [parameter( Mandatory = $false, ParameterSetName='client_secret_jwt', HelpMessage="Hashtable with custom claims.")]
        [hashtable]$customClaims,

        [parameter( Mandatory = $true, ParameterSetName='private_key_jwt', HelpMessage="Location Cert:\CurrentUser\My\THUMBPRINT, x509certificate2 or RSA Private key.")]
        $client_certificate,

        [parameter( Mandatory = $false, ParameterSetName='private_key_jwt', HelpMessage="key identifier for assertion header")]
        $key_id,

        [parameter( Mandatory = $true, ParameterSetName='client_secret_jwt', HelpMessage="ClientSecret")]
        $client_secret
    )
    $jwtHeader = @{ alg = "RS256"; typ = "JWT" }
    # certificate properties
    if ( $client_certificate ) {
        if ( $client_certificate.GetType().Name -notmatch "^X509Certificate|^RSA" ) {
            try { $client_certificate = Get-Item $client_certificate -ErrorAction Stop }
            catch { throw $_ }
        }
        if ( $client_certificate.GetType().Name -match "^X509Certificate" ) { $jwtHeader.x5t = ConvertTo-Base64urlencoding $client_certificate.GetCertHash() }
        if ( $key_id ) { $jwtHeader.kid = $key_id }
    }
    elseif ( $client_secret ) {
        if ( $client_secret.GetType().Name -eq "SecureString" ) { 
            # Psv5 ConvertFrom-SecureString does not have -AsPlainText Param
            if ( $PSVersionTable.PSEdition -eq "Core" ) { $client_secret = $client_secret | ConvertFrom-SecureString -AsPlainText }
            else {
                # secureString.toBinaryString.toStringUnit
                $client_secret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($client_secret)
                )
            }
        }
    }
    $jwtHeader = $jwtHeader | ConvertTo-Json
    # build assertion payload
    $jwtClaims = @{
        aud = $audience                 # URL of the resource using the JWT to authenticate to
        exp = (Get-UnixTime) + 300      # expiration time of the token
        jti = $jwtId                    # (optional) unique identifier for the token
        iat = Get-UnixTime              # (optional) time the token was issued
        iss = $issuer                   # issuer of token (client_id)
        sub = $subject                  # subject of the token (client_id)
        nbf = Get-UnixTime              # (optional) time before which the token is not valid
    } 
    if ( $customClaims ) { foreach ( $key in $customClaims.Keys ) { $jwtClaims.$key = $customClaims[$key] } }
    $jwtClaims = $jwtClaims | ConvertTo-Json
    # unsigned assertion in base64url encoding
    $jwtAssertion = (ConvertTo-Base64urlencoding $jwtHeader) + "." + (ConvertTo-Base64urlencoding $jwtClaims)
    # assertion signing - cert or secret
    if ( $client_certificate ) {
        if ( $client_certificate.GetType().Name -match "^X509" ) { $signature = convertTo-Base64urlencoding $client_certificate.PrivateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($jwtAssertion),[Security.Cryptography.HashAlgorithmName]::SHA256,[Security.Cryptography.RSASignaturePadding]::Pkcs1) }
        elseif ( $client_certificate.GetType().Name -match "^RSA" ) { $signature = convertTo-Base64urlencoding $client_certificate.SignData([System.Text.Encoding]::UTF8.GetBytes($jwtAssertion),[Security.Cryptography.HashAlgorithmName]::SHA256,[Security.Cryptography.RSASignaturePadding]::Pkcs1) }
    }
    else { 
        $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
        $hmacsha.key = [Text.Encoding]::UTF8.GetBytes($client_secret)
        $signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($jwtAssertion))
        $signature = convertTo-Base64urlencoding ( [Convert]::ToBase64String($signature) )
    }
    # Finalize response
    $response = [ordered]@{}
    $response.client_assertion_jwt = $jwtAssertion + "." + $Signature
    $response.client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    $response.header = $jwtHeader | ConvertFrom-Json
    $response.payload = $jwtClaims  | ConvertFrom-Json
    return $response
}