function Invoke-OAuth2TokenEndpoint { 
    <#
    .SYNOPSIS
    Token Exchange by OAuth2.0 Token Endpoint interaction.

    .DESCRIPTION
    Forge and send token exchange requests to the OAuth2.0 Token Endpoint.

    .PARAMETER uri
    Authorization endpoint URL.

    .PARAMETER client_id
    The identifier of the client at the authorisation server. (required if no other client authentication is present)

    .PARAMETER redirect_uri
    The client callback URI for the response. (required if it was included in the initial authorization request)

    .PARAMETER scope
    One or more space-separated strings indicating which permissions the application is requesting. 

    .PARAMETER code
    Authorization code received from the authorization server.

    .PARAMETER code_verifier
    Code_verifier, required if code_challenge was used in the authorization request (PKCE).

    .PARAMETER device_code
    Device verification code received from the authorization server.

    .PARAMETER client_secret
    client credential as string or securestring

    .PARAMETER client_auth_method
    OPTIONAL client (secret) authentication method. (default: client_secret_post)

    .PARAMETER client_certificate
    client credential as x509certificate2, RSA Private key or cert location 'Cert:\CurrentUser\My\THUMBPRINT'

    .PARAMETER nonce
    OPTIONAL nonce value used to associate a Client session with an ID Token, and to mitigate replay attacks.

    .PARAMETER refresh_token
    Refresh token received from the authorization server.

    .PARAMETER customHeaders
    Hashtable with custom headers to be added to the request uri (e.g. User-Agent, Origin, Referer, etc.).

    .EXAMPLE
    PS> $code = Invoke-OAuth2AuthorizationEndpoint -uri $authorization_endpoint @splat
    PS> Invoke-OAuth2TokenEndpoint -uri $token_endpoint @code
    token_type      : Bearer
    scope           : User.Read profile openid email
    expires_in      : 4948
    ext_expires_in  : 4948
    access_token    : eyJ0eXAiOiJKV1QiLCJujHu5ZSI6IllQUWFERGtkVEczUjJIYm5tWFlhOG1QbHk1ZTlwckJybm...
    refresh_token   : 0.AUcAjvFfm8BTokWLwpwMkH65xiGBP5hz2ZpErJuc3chlhOUNAVw.AgABAAEAAAAmoFfGtYxv...
    id_token        : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2...
    expiry_datetime : 01.02.2024 12:51:33

    Invokes the Token Endpoint by passing parameters from the authorization endpoint response such as code, code_verifier, nonce, etc.

    .EXAMPLE 
    PS> Invoke-OAuth2TokenEndpoint -uri $token_endpoint -scope ".default" -client_id "123" -client_secret "secret"
    token_type      : Bearer
    expires_in      : 3599
    ext_expires_in  : 3599
    access_token    : eyJ0eXAiOiJKV1QikjY6b25jZSI6IkZ4YTZ4QmloQklGZjFPT0FqQZQ4LTl5WUEtQnpqdXNzTn...
    expiry_datetime : 01.02.2024 12:33:01

    Client authentication using client_secret_post

    .EXAMPLE
    PS> Invoke-OAuth2TokenEndpoint -uri $token_endpoint -scope ".default" -client_id "123" "Cert:\CurrentUser\My\8kge399dddc5521e04e34ac19fe8f8759ba021b8"
    token_type      : Bearer
    expires_in      : 3599
    ext_expires_in  : 3599
    access_token    : eyJ0eXYiOiJKV1QiLCJusk6jZSI6IlNkYU9lOTdtY0NqS0g1VnRURjhTY3JSMEgwQ0hje24fR1...
    expiry_datetime : 01.02.2024 12:36:17

    Client authentication using private_key_jwt

    #>
    [Alias('Invoke-TokenEndpoint','token')]
    [cmdletbinding(DefaultParameterSetName='code')]
    param(
        [parameter( Position = 0, Mandatory = $true, ParameterSetName='client_certificate')]    
        [parameter( Position = 0, Mandatory = $true, ParameterSetName='client_secret')]
        [parameter( Position = 0, Mandatory = $true, ParameterSetName='code')]
        [parameter( Position = 0, Mandatory = $true, ParameterSetName='device_code')]
        [parameter( Position = 0, Mandatory = $true, ParameterSetName='refresh')]
        [string]$uri,

        [parameter( Mandatory = $false, ParameterSetName='client_certificate')]
        [parameter( Mandatory = $false, ParameterSetName='client_secret')]
        [parameter( Mandatory = $false, ParameterSetName='code')]
        [parameter( Mandatory = $false, ParameterSetName='device_code')]
        [parameter( Mandatory = $false, ParameterSetName='refresh')]
        [string]$client_id,

        [parameter( Mandatory = $false, ParameterSetName='client_certificate')]
        [parameter( Mandatory = $false, ParameterSetName='client_secret')]
        [parameter( Mandatory = $false, ParameterSetName='code')]
        [parameter( Mandatory = $false, ParameterSetName='refresh')]
        [string]$redirect_uri,

        [parameter(Mandatory = $false, ParameterSetName='client_certificate')]
        [parameter(Mandatory = $false, ParameterSetName='client_secret')]
        [parameter(Mandatory = $false, ParameterSetName='code')]
        [parameter(Mandatory = $false, ParameterSetName='refresh')]
        [string]$scope,

        [parameter( Mandatory = $false, ParameterSetName='client_certificate')]
        [parameter( Mandatory = $false, ParameterSetName='client_secret')]
        [parameter( Mandatory = $false, ParameterSetName='code')]
        [string]$code,

        [parameter( Mandatory = $false, ParameterSetName='client_certificate')]
        [parameter( Mandatory = $false, ParameterSetName='client_secret')]
        [parameter( Mandatory = $false, ParameterSetName='code')]
        [string]$code_verifier,

        [parameter( Mandatory = $true, ParameterSetName='device_code')]
        [string]$device_code,

        [parameter( Mandatory = $true, ParameterSetName='client_secret')]
        [parameter( Mandatory = $false, ParameterSetName='code')]
        [parameter( Mandatory = $false, ParameterSetName='refresh')]
        $client_secret,

        [parameter( Mandatory = $false, ParameterSetName='client_secret', HelpMessage="client_credential type")]
        [parameter( Mandatory = $false, ParameterSetName='refresh')]
        [ValidateSet('client_secret_basic','client_secret_post','client_secret_jwt')]
        $client_auth_method = "client_secret_post",

        [parameter( Mandatory = $true, ParameterSetName='client_certificate', HelpMessage="private_key_jwt")]
        [parameter( Mandatory = $false, ParameterSetName='refresh', HelpMessage="private_key_jwt")]
        $client_certificate,

        [parameter( Mandatory = $false, ParameterSetName='client_certificate')]
        [parameter( Mandatory = $false, ParameterSetName='client_secret')]
        [parameter( Mandatory = $false, ParameterSetName='code')]
        [parameter( Mandatory = $false, ParameterSetName='refresh')]
        [string]$nonce,

        [parameter( Mandatory = $true, ParameterSetName='refresh')]
        $refresh_token,

        [parameter( Mandatory = $false, ParameterSetName='client_certificate')]
        [parameter( Mandatory = $false, ParameterSetName='client_secret')]
        [parameter( Mandatory = $false, ParameterSetName='code')]
        [parameter( Mandatory = $false, ParameterSetName='device_code')]
        [parameter( Mandatory = $false, ParameterSetName='refresh')]
        [hashtable]$customHeaders
    )

    $payload = @{}
    $payload.headers = @{ 'Content-Type' = 'application/x-www-form-urlencoded' }
    $payload.method  = 'Post'
    $payload.uri     =  $uri

    # Custom headers provided
    if ( $customHeaders ) { 
        if ( $customHeaders.Keys -contains "Content-Type" ) { $payload.headers = $customHeaders }
        else { $payload.headers += $customHeaders }
    }
    
    # Build request body and determine grant_type
    $requestBody = @{}
    if ( $client_id ) { $requestBody.client_id = $client_id }
    if ( $redirect_uri ) { $requestBody.redirect_uri = $redirect_uri }
    if ( $scope ) { $requestBody.scope = $scope }
    if ( ( $client_secret -or $client_certificate) -and !$code -and !$refresh_token ) { 
        $requestBody.grant_type = "client_credentials" 
    }
    elseif ( $code ) { 
        $requestBody.grant_type = "authorization_code"
        $requestBody.code = $code 
        if ( $code_verifier ) { $requestBody.code_verifier = $code_verifier }
    }
    elseif ( $device_code ) { 
        $requestBody.grant_type = "urn:ietf:params:oauth:grant-type:device_code"
        $requestBody.device_code = $device_code
    }
    elseif ( $refresh_token ) { 
        $requestBody.grant_type = "refresh_token"
        $requestBody.refresh_token = $refresh_token
    }

    # client authentication
    if ( $client_secret ) { 
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
        switch ( $client_auth_method ) {
            "client_secret_basic" { $payload.headers.Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("$($client_id):$($client_secret)")) }
            "client_secret_post" { $requestBody.client_secret = $client_secret }
            "client_secret_jwt" { $requestBody.client_assertion = (New-Oauth2JwtAssertion -aud $uri -iss $client_id -sub $client_id -client_secret $client_secret -ErrorAction Stop).client_assertion_jwt }
        }
    }
    elseif ( $client_certificate) {
        if ( $client_certificate.GetType().Name -notmatch "^X509Certificate|^RSA" ) {
            try { $client_certificate = Get-Item $client_certificate -ErrorAction Stop }
            catch { throw $_ }
        }
        $requestBody.client_assertion = (New-Oauth2JwtAssertion -aud $uri -iss $client_id -sub $client_id -client_certificate $client_certificate -ErrorAction Stop).client_assertion_jwt
    }
    if ( $client_certificate -or $client_auth_method -eq "client_secret_jwt" ) { $requestBody.client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"}

    $payload.body = $requestBody
    write-verbose ($payload | ConvertTo-Json -Compress)
    try { $response = Invoke-RestMethod @payload -Verbose:$false }
    catch { throw $_ }

    # validate id_token nonce
    if ( $nonce -and $response.id_token ) { 
        $decodedToken = ConvertFrom-JsonWebToken $response.id_token -Verbose:$false
        if ( $decodedToken.nonce -ne $nonce ) { throw "id_token nonce mismatch`nExpected '$nonce', got '$($decodedToken.nonce)'." }
        Write-Verbose "Invoke-OAuth2TokenExchange: Validated nonce in id_token"
    }

    # add expiry datetime
    if ( $response.expires_in ) { $response | Add-Member -NotePropertyName expiry_datetime -TypeName NoteProperty (get-date).AddSeconds($response.expires_in) }
    
    # badabing badaboom
    return $response
}