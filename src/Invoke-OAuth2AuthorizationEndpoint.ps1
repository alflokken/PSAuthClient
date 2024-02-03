function Invoke-OAuth2AuthorizationEndpoint { 
    <#
    .SYNOPSIS
    Interact with a OAuth2 Authorization endpoint.

    .DESCRIPTION
    Uses WebView2 (embedded browser based on Microsoft Edge) to request authorization, this ensures support for modern web pages and capabilities like SSO, Windows Hello, FIDO key login, etc

    OIDC and OAUTH2 Grants such as Authorization Code Flow with PKCE, Implicit Flow (including form_post) and Hybrid Flows are supported

    .PARAMETER uri
    Authorization endpoint URL.

    .PARAMETER client_id
    The identifier of the client at the authorisation server.

    .PARAMETER redirect_uri
    The client callback URI for the authorisation response.

    .PARAMETER response_type
    Tells the authorization server which grant to execute. Default is code.

    .PARAMETER scope
    One or more space-separated strings indicating which permissions the application is requesting. 

    .PARAMETER usePkce
    Proof Key for Code Exchange (PKCE) improves security for public clients by preventing and authorization code attacks. Default is $true.

    .PARAMETER response_mode
    OPTIONAL Informs the Authorization Server of the mechanism to be used for returning Authorization Response. Determined by response_type, if not specified.

    .PARAMETER customParameters
    Hashtable with custom parameters to be added to the request uri (e.g. domain_hint, prompt, etc.)

    .EXAMPLE
    PS> Invoke-OAuth2AuthorizationEndpoint -uri "https://acc.spotify.com/authorize" -client_id "2svXwWbFXj" -scope "user-read-currently-playing" -redirect_uri "http://localhost"
        
    code_verifier                  xNTKRgsEy_u2Y.PQZTmUbccYd~gp7-5v4HxS7HVKSD2fE.uW_yu77HuA-_sOQ...
    redirect_uri                   https://localhost
    client_id                      2svXwWbFXj
    code                           AQDTWHSP6e3Hx5cuJh_85r_3m-s5IINEcQZzjAZKdV4DP_QRqSHJzK_iNB_hN...

    A request for user authorization is sent to the /authorize endpoint along with a code_challenge, code_challenge_method and state param. If successful, the authorization server 
    will redirect back to the redirect_uri with a code which can be exchanged for an access token.
    
    .EXAMPLE
    PS> Invoke-OAuth2AuthorizationEndpoint -uri "https://example.org/oauth2/authorize" -client_id "0325" -redirect_uri "http://localhost" -scope "user.read" -response_type "token" -usePkce:$false -customParameters @{ login = "none" }

    expires_in                     4146
    expiry_datetime                01.02.2024 10:56:06
    scope                          User.Read profile openid email
    session_state                  5c044a21-543e-4cbc-a94r-d411ddec5a87
    access_token                   eyJ0eXAiQiJKV1QiLCJub25jZSI6InAxYTlHksH6bktYdjhud3VwMklEOGtUM...
    token_type                     Bearer

    Implicit grant flow
    #>
    [Alias('Invoke-AuthorizationEndpoint','authorize')]
    [OutputType([hashtable])]
    param(
        [parameter(Position = 0, Mandatory = $true)]
        [string]$uri,

        [parameter( Mandatory = $true)]
        [string]$client_id,

        [parameter( Mandatory = $false)]
        [string]$redirect_uri,
        
        [parameter( Mandatory = $false)]
        [validatePattern("(code)?(id_token)?(token)?(none)?")]
        [string]$response_type = "code",

        [parameter( Mandatory = $false)]
        [string]$scope,

        [parameter( Mandatory = $false)]
        [bool]$usePkce = $true,

        [parameter( Mandatory = $false)]
        [ValidateSet("query","fragment","form_post")]
        [string]$response_mode,

        [parameter( Mandatory = $false)]
        [hashtable]$customParameters
    )

    # Arbitrary string value to be verified in the response, prevent cross-site request forgery (CSRF) (can also be used to uniquely identify a session).
    [string]$state = Get-RandomString -Length ( (16..21) | get-random )

    # build request uri
    $uri += "?response_type=$([System.Web.HttpUtility]::UrlEncode($response_type))&client_id=$client_id&state=$state"
    
    # PKCE for code flows
    if ( $response_type -notmatch "code" -and $usePkce ) { write-verbose "Invoke-OAuth2AuthorizationRequest: PKCE is not supported for implicit flows." }
    else { 
        if ( $usePkce ) {
            $pkce = New-PkceChallenge 
            $uri += "&code_challenge=$($pkce.code_challenge)&code_challenge_method=$($pkce.code_challenge_method)"
        }
    }

    # Determine protocol being used.
    if ( $response_type -eq "token" -or ($response_type -match "^code$" -and $scope -notmatch "openid" ) ) { 
        $protocol = "OAUTH" 
        $nonce = $null
    }
    else { $protocol = "OIDC"
        # ensure scope contains openid for oidc flows
        if ( $scope -notmatch "openid" ) { Write-Warning "Invoke-OAuth2AuthorizationRequest: Added openid scope to request (OpenID requirement)."; $scope += " openid" }
        # generate nonce for id_token validation
        [string]$nonce = Get-RandomString -Length ( (32..64) | get-random ); $uri += "&nonce=$nonce"
        Write-Verbose "Invoke-OAuth2AuthorizationRequest: adding nonce $nonce to request (OIDC flow)."
    }

    # Add scope and redirect_uri to request uri
    if ( $redirect_uri -or $scope ) { 
        Add-Type -AssemblyName System.Web -ErrorAction Stop
        if ( $redirect_uri ) { $uri += "&redirect_uri=$([System.Web.HttpUtility]::UrlEncode($redirect_uri))" } 
        if ( $scope ) { $uri += "&scope=$([System.Web.HttpUtility]::UrlEncode($scope))" }
    }

    # Add custom parameters to request uri
    if ( $customParameters ) { 
        foreach ( $key in $customParameters.Keys ) { $uri += "&$key=$($customParameters[$key])" }
    }
    Write-Verbose "Invoke-OAuth2AuthorizationRequest $protocol request uri $uri"
    
    # form_post response_mode: start http.sys listener as job and give it some time to start
    if ( $response_mode -eq "form_post" ) { 
        $uri += "&response_mode=form_post"
        $job = Start-Job -ScriptBlock (Get-Command 'New-HttpListener').ScriptBlock -ArgumentList $redirect_uri
        Start-Sleep -Milliseconds 500
    }

    # authorization request (interactive)
    $webSource = Invoke-WebView2 -uri $uri -UrlCloseConditionRegex "$redirect_uri|error=[^&]*|code=[^&]*" -title "Authorization code flow"
    
    # job should be running (awaiting request) if no error occured
    if ( $response_mode -eq "form_post" ) {
        Write-Verbose "Invoke-OAuth2AuthorizationRequest: http.sys waiting for form_post request. (timeout 10s)"
        Wait-Job $job -Timeout 10 | Out-Null
        if ( $job.State -eq "Running" ) { 
            Write-Verbose "Invoke-OAuth2AuthorizationRequest: http.sys did not receive form_post request before timeout (10s)."; Stop-Job $job; Remove-Job $job
            throw "Invoke-OAuth2AuthorizationRequest: did not receive form_post request before timeout (10s)."
        }

        try { $jobData = Receive-Job $job -ErrorAction Stop }
        catch { 
            if ( $_.Exception.Message -match "Access is denied." ) { throw "Unabled to start http.sys listener, please run as admin." }
            else { throw "http.sys listener failed, error: $($jobData.Exception.Message)" }
        }
        finally { Remove-Job $job }
        Write-Verbose "Invoke-OAuth2AuthorizationRequest: http.sys form_post request received."
        $webSource = @{ Fragment = $jobData; Query = $null }
    }

    # When the window closes, the script will continue and retreive the auth code from the url source
    # Token retreival dependent on response_mode
    if( $webSource.query -match "code=" ) {
        $response = @{}
        $response.code = [System.Web.HttpUtility]::ParseQueryString($webSource.Query)['code']
        $response.state = [System.Web.HttpUtility]::ParseQueryString($webSource.Query)['state']
        if ( $protocol -eq "oidc" ) { 
            $response.nonce = $nonce 
            if ( [System.Web.HttpUtility]::ParseQueryString($webSource.Query)['access_token'] ) { $response.access_token = [System.Web.HttpUtility]::ParseQueryString($webSource.Query)['access_token'] }
            if ( [System.Web.HttpUtility]::ParseQueryString($webSource.Query)['id_token'] ) { $response.access_token = [System.Web.HttpUtility]::ParseQueryString($webSource.Query)['id_token'] }
        }
    } 
    elseif ( $webSource.Query -match "error=" ) { 
        $errorDetails = [ordered]@{}
        $errorDetails.error = [System.Web.HttpUtility]::ParseQueryString($webSource.Query)['error']
        $errorDetails.error_uri = [System.Web.HttpUtility]::ParseQueryString($webSource.Query)['error_uri']
        $errorDetails.error_description = [System.Web.HttpUtility]::ParseQueryString($webSource.Query)['error_description']
        throw ($errorDetails | convertTo-Json)
    }
    elseif ( $webSource.Fragment -match "token|error=" ) {
        $response = @{}
        foreach ( $item in (($webSource.Fragment -split "#|&") | Where-Object { $_ -ne "" }) ) { 
            $key = $item.split("=")[0]
            $value = $item.split("=")[1]
            $value = [System.Web.HttpUtility]::UrlDecode($value)
            $response.$key = $value
        }
        if ( $protocol -eq "oidc" ) { $response.nonce = $nonce }
        if ( $webSource.Fragment -match "error=" ) { throw ($response | Select-Object * -ExcludeProperty state | convertTo-Json) }
    }
    else { throw "invalid response received" }

    # if code flow, add client_id, code_verifier and redirect_uri to response (needed for token exchange) 
    if ( $response_type -match "code" ) {
        $response.client_id = $client_id
        if ( $usePkce ) { $response.code_verifier = $pkce.code_verifier }
        if ( $redirect_uri ) { $response.redirect_uri = $redirect_uri }
    }

    # verify state
    if ( $response.state -ne $state ) { throw "State mismatch!`nExpected '$state', got '$($response.state)'." }
    else { Write-Verbose "Invoke-OAuth2AuthorizationRequest: Validated state in response." }

    # validate id_token nonce
    if ( $nonce -and $response.ContainsKey("id_token") ) { 
        $decodedToken = ConvertFrom-JsonWebToken $response.id_token -Verbose:$false
        if ( $decodedToken.nonce -ne $nonce ) { throw "id_token nonce mismatch`nExpected '$nonce', got '$($decodedToken.nonce)'." }
        Write-Verbose "Invoke-OAuth2TokenExchange: Validated nonce in id_token response."
    }

    # add expiry datetime to response
    if ( $response.ContainsKey("expires_in") ) { 
        $response["expires_in"] = [int]$response["expires_in"]
        $response.expiry_datetime = (get-date).AddSeconds($response.expires_in) 
    }
    
    # remove state from response
    if ( $response.ContainsKey("state") ) { $response.Remove("state") }

    # badabing badaboom
    return $response
}