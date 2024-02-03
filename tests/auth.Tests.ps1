param ( [string]$ModulePath = "$PSScriptRoot\..\release\PSAuthClient.psd1" )

BeforeAll {
    try { 
        Import-Module $ModulePath -ErrorAction Stop 
        # load Invoke-Cache from gist
        if ( !(Get-Command Invoke-Cache -ErrorAction SilentlyContinue) ) { 
            Invoke-Expression (Invoke-RestMethod "https://gist.github.com/alflokken/af4f98b5477415a191c3a99e3866123c/raw/8e90d6ec878bc569cf5d058dee74b9edb6b012c6/Invoke-Cache.ps1") 
        }
    }
    catch { throw "Failed to load dependencies" }

    # build settings from json
    $config = Get-Content "$PSScriptRoot\clientConfiguration.json" | ConvertFrom-Json
    $config.client_secret = (Invoke-Cache -keyname $config.client_secret -asSecureString)

    $splat = @{};foreach ( $property in $config.splat.PSObject.Properties ) { $splat[$property.Name] = $property.Value }
    $splat.customParameters = @{ prompt = "none" }
}
Describe "Prerequisites" {
    It "Should have a valid client_id" { $splat.client_id | Should -Not -BeNullOrEmpty }
    It "Should have a valid tenantId" { $config.tenantId | Should -Not -BeNullOrEmpty }
    It "Should have a client_certificate" { $config.client_certificate | Should -Exist }
    It "Should have a client_secret" { $config.client_secret | Should -Not -BeNullOrEmpty }
}
Describe "Authorization Code Grant" {
    context "Authorization Code Grant with Proof Key for Code Exchange (PKCE)." { 
        BeforeAll { 
            $code = Invoke-OAuth2AuthorizationEndpoint -uri $config.authorization_endpoint @splat 
            $token = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint @code
        }
        It "Authorization should return a code and code_verifier." { 
            $code.code | Should -Not -BeNullOrEmpty
            $code.code_verifier | Should -Not -BeNullOrEmpty
        }
        It "Invoke-OAuth2AuthorizationEndpoint should return a nonce for OIDC Flows." { 
            $code.nonce | Should -Not -BeNullOrEmpty
        }
        It "Invoke-Oauth2AuthorizationEndpoint should return a hashtable with properties which can be used as a splat for Invoke-OAuth2TokenEndpoint." { 
            $code | Should -BeOfType Hashtable
            $code.client_id | Should -Be $splat.client_id
            $code.redirect_uri | Should -Be $splat.redirect_uri
        }
        It "code exchange response should contain 'id_token', 'access_token' and 'refresh_token'." { 
            $token.token_type | Should -Be "Bearer"
            $token.access_token | Should -Not -BeNullOrEmpty
            $token.id_token | Should -Not -BeNullOrEmpty
            $token.refresh_token | Should -Not -BeNullOrEmpty
        }
        It "Invoke-OAuth2TokenEndpoint: should also return scope and expiry information" { 
            $token.expires_in | Should -BeGreaterThan 60
            $token.expiry_datetime | Should -BeOfType System.DateTime
            $token.scope | Should -Not -BeNullOrEmpty
        }
    }
    context "Authorization Code Grant" { 
        BeforeAll { 
            $code = Invoke-OAuth2AuthorizationEndpoint -uri $config.authorization_endpoint @splat -usePkce:$false
            $token = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint @code
        }
        It "Authorization should return a code (and no code_verifier)." { 
            $code.code | Should -Not -BeNullOrEmpty
            $code.Keys | Should -Not -Contain "code_verifier"
        }
        It "Invoke-OAuth2AuthorizationEndpoint should return a nonce for OIDC Flows." { 
            $code.nonce | Should -Not -BeNullOrEmpty
        }
        It "Invoke-Oauth2AuthorizationEndpoint should return a hashtable with properties which can be used as a splat for Invoke-OAuth2TokenEndpoint." { 
            $code | Should -BeOfType Hashtable
            $code.client_id | Should -Be $splat.client_id
            $code.redirect_uri | Should -Be $splat.redirect_uri
        }
        It "code exchange response should contain 'id_token', 'access_token' and 'refresh_token'." { 
            $token.token_type | Should -Be "Bearer"
            $token.access_token | Should -Not -BeNullOrEmpty
            $token.id_token | Should -Not -BeNullOrEmpty
            $token.refresh_token | Should -Not -BeNullOrEmpty
        }
        It "Invoke-OAuth2TokenEndpoint: should also return scope and expiry information" { 
            $token.expires_in | Should -BeGreaterThan 60
            $token.expiry_datetime | Should -BeOfType System.DateTime
            $token.scope | Should -Not -BeNullOrEmpty
        }
    }
    context "Authorization Code Grant with Client Authentication (secret)" {
        BeforeAll {
            $splat.redirect_uri = "https://localhost/web"
            $code = Invoke-OAuth2AuthorizationEndpoint -uri $config.authorization_endpoint @splat 
            $token = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint @code -client_secret $config.client_secret
        }
        It "code exchange response should contain 'id_token', 'access_token' and 'refresh_token'." { 
            $token.token_type | Should -Be "Bearer"
            $token.access_token | Should -Not -BeNullOrEmpty
            $token.id_token | Should -Not -BeNullOrEmpty
            $token.refresh_token | Should -Not -BeNullOrEmpty
        }
        It "Invoke-OAuth2TokenEndpoint: should also return scope and expiry information" { 
            $token.expires_in | Should -BeGreaterThan 60
            $token.expiry_datetime | Should -BeOfType System.DateTime
            $token.scope | Should -Not -BeNullOrEmpty
        }
    }
}
Describe "Refresh Token Grant" {
    BeforeAll { 
        $splat.redirect_uri = "https://login.microsoftonline.com/common/oauth2/nativeclient"
        $code = Invoke-OAuth2AuthorizationEndpoint -uri $config.authorization_endpoint @splat 
        $token = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint @code
        $token = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint -refresh_token $token.refresh_token -client_id $splat.client_id -scope $splat.scope -nonce $code.nonce 
    }
    It "refresh_token code exchange should return a 'id_token', 'access_token' and 'refresh_token'." { 
        $token.token_type | Should -Be "Bearer"
        $token.access_token | Should -Not -BeNullOrEmpty
        $token.id_token | Should -Not -BeNullOrEmpty
        $token.refresh_token | Should -Not -BeNullOrEmpty
    }
    It "Invoke-Oauth2TokenEndpoint: should also return scope and expiry information" { 
        $token.expires_in | Should -BeGreaterThan 60
        $token.expiry_datetime | Should -BeOfType System.DateTime
        $token.scope | Should -Not -BeNullOrEmpty
    }
}
Describe "OAuth2.0 Device Authorization Grant" {
    BeforeAll {
        $deviceCode = Invoke-OAuth2DeviceAuthorizationEndpoint -uri "https://login.microsoftonline.com/$($config.tenantId)/oauth2/v2.0/devicecode" -client_id $splat.client_id -scope $splat.scope
        . "$PSScriptRoot\..\src\internal\Invoke-WebView2.ps1"
        Invoke-WebView2 -uri "https://microsoft.com/devicelogin" -UrlCloseConditionRegex "//appverify$" -title "Device Code Flow" | Out-Null
        $token = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint -device_code $deviceCode.device_code -client_id $splat.client_id
    }
    it "Device Authorization should return device_code, user_code, verification_uri and expires_in." { 
        $deviceCode.device_code | Should -Not -BeNullOrEmpty
        $deviceCode.user_code | Should -Not -BeNullOrEmpty
        $deviceCode.verification_uri | Should -Not -BeNullOrEmpty
        $deviceCode.expires_in | Should -BeGreaterThan 60
    }
    It "Code Exchange should return access_token." { 
        $token.token_type | Should -Be "Bearer"
        $token.access_token | Should -Not -BeNullOrEmpty
    }
    It "Invoke-OAuth2TokenEndpoint: should also return scope and expiry information" { 
        $token.expires_in | Should -BeGreaterThan 60
        $token.expiry_datetime | Should -BeOfType System.DateTime
        $token.scope | Should -Not -BeNullOrEmpty
    }
}
Describe "Confidential Clients" {
    context "Client Credentials Grant" {
        BeforeAll { 
            $splat.Remove("customParameters")
            $splat.scope = ".default"
            $splat.redirect_uri = "https://login.microsoftonline.com/common/oauth2/nativeclient"
            $client_secret_basic = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint @splat -client_secret $config.client_secret -client_auth_method client_secret_basic
            $client_secret_post = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint @splat -client_secret $config.client_secret
            $private_key_jwt = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint @splat -client_certificate $config.client_certificate
        }
        It "client_credentials (client_secret_basic) should return access_token." { 
            $client_secret_basic.token_type | Should -Be "Bearer"
            $client_secret_basic.access_token | Should -Not -BeNullOrEmpty
            $client_secret_basic.expires_in | Should -BeGreaterThan 60
            $client_secret_basic.expiry_datetime | Should -BeOfType System.DateTime
        }
        It "client_credentials (client_secret_post) should return access_token." { 
            $client_secret_post.token_type | Should -Be "Bearer"
            $client_secret_post.access_token | Should -Not -BeNullOrEmpty
            $client_secret_post.expires_in | Should -BeGreaterThan 60
            $client_secret_post.expiry_datetime | Should -BeOfType System.DateTime
        }
        It "client_credentials (private_key_jwt) should return access_token." { 
            $private_key_jwt.token_type | Should -Be "Bearer"
            $private_key_jwt.access_token | Should -Not -BeNullOrEmpty
            $private_key_jwt.expires_in | Should -BeGreaterThan 60
            $private_key_jwt.expiry_datetime | Should -BeOfType System.DateTime
        }
    }
}
Describe "Public Clients" {
    context "OAuth 2.0 Implicit Grant" {
        BeforeAll { $token = Invoke-OAuth2AuthorizationEndpoint -uri $config.authorization_endpoint @splat -response_type "token" -usePkce:$false -WarningAction:SilentlyContinue }
        It "Authorization Endpoint should return access_token, scope and expiry information." { 
            $token.token_type | Should -Be "Bearer"
            $token.access_token | Should -Not -BeNullOrEmpty
            $token.expires_in | Should -BeGreaterThan 60
            $token.expiry_datetime | Should -BeOfType System.DateTime
        }
    }
    context "OIDC Implicit Grant" {
        BeforeAll {
            $splat.redirect_uri = "https://localhost/spa"
            $splat.scope = "User.Read"
            $token = Invoke-OAuth2AuthorizationEndpoint -uri $config.authorization_endpoint @splat -response_type "token id_token" -usePkce:$false -WarningAction:SilentlyContinue
        }
        It "Authorization Endpoint should return access_token, id_token (nonce), scope and expiry information." { 
            $token.token_type | Should -Be "Bearer"
            $token.access_token | Should -Not -BeNullOrEmpty
            $token.id_token | Should -Not -BeNullOrEmpty
            $token.nonce | Should -Not -BeNullOrEmpty
            $token.expires_in | Should -BeGreaterThan 60
            $token.expiry_datetime | Should -BeOfType System.DateTime
        }
    }
    context "Hybrid Grant" {
        BeforeAll { 
            $splat.scope = "user.read openid offline_access"
            $splat.redirect_uri = "http://localhost"
            $splat.usePkce = $true
            $hybrid_code = Invoke-OAuth2AuthorizationEndpoint -uri $config.authorization_endpoint @splat -response_type "code id_token"
            # preserve id token
            $id_token = $hybrid_code.id_token
            # code exchange
            $hybrid_code.Remove("id_token"); $hybrid_code.Remove("session_state")
            $token = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint @hybrid_code
        }
        It "Authorization Endpoint should return code and id_token (nonce)." { 
            $hybrid_code.code | Should -Not -BeNullOrEmpty
            $hybrid_code.code_verifier | Should -Not -BeNullOrEmpty
            $hybrid_code.redirect_uri | Should -Not -BeNullOrEmpty
            $id_token | Should -Not -BeNullOrEmpty
            $hybrid_code.nonce | Should -Not -BeNullOrEmpty
        }
        It "code exchange response should contain 'id_token', 'access_token' and 'refresh_token'." { 
            $token.token_type | Should -Be "Bearer"
            $token.access_token | Should -Not -BeNullOrEmpty
            $token.id_token | Should -Not -BeNullOrEmpty
            $token.refresh_token | Should -Not -BeNullOrEmpty
        }
        It "Invoke-OAuth2TokenEndpoint: should also return scope and expiry information" { 
            $token.expires_in | Should -BeGreaterThan 60
            $token.expiry_datetime | Should -BeOfType System.DateTime
            $token.scope | Should -Not -BeNullOrEmpty
        }
    }
    context "Implicit Grant with Form_Post" {
        BeforeAll { 
            BeforeAll { 
                $splat.redirect_uri = "http://localhost:5001/"
                $customParameters = @{ prompt = "none" }
                $token = Invoke-OAuth2AuthorizationEndpoint -uri $config.authorization_endpoint @splat -response_type "code id_token" -response_mode "form_post"
                # preserve id_token
                $id_token = $token.id_token
                $token.Remove("id_token"); $token.Remove("session_state")
                $token = Invoke-OAuth2TokenEndpoint -uri $config.token_endpoint @token
            }
            It "Authorization Endpoint should return code, id_token (nonce), scope and expiry information." { 
                $token.code | Should -Not -BeNullOrEmpty
                $id_token | Should -Not -BeNullOrEmpty
                $token.nonce | Should -Not -BeNullOrEmpty
                $token.expires_in | Should -BeGreaterThan 60
                $token.expiry_datetime | Should -BeOfType System.DateTime
            }
            It "code exchange response should contain 'id_token', 'access_token' and 'refresh_token'." { 
                $token.token_type | Should -Be "Bearer"
                $token.access_token | Should -Not -BeNullOrEmpty
                $token.id_token | Should -Not -BeNullOrEmpty
                $token.refresh_token | Should -Not -BeNullOrEmpty
            }
            It "Invoke-OAuth2TokenEndpoint: should also return scope and expiry information" { 
                $token.expires_in | Should -BeGreaterThan 60
                $token.expiry_datetime | Should -BeOfType System.DateTime
                $token.scope | Should -Not -BeNullOrEmpty
            }
        }
    }
}