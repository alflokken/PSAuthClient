param ( [string]$ModulePath = "$PSScriptRoot\..\release\PSAuthClient.psd1" )
BeforeAll {
    # build settings from json
    $config = Get-Content "$PSScriptRoot\clientConfiguration.json" | ConvertFrom-Json
    $splat = @{};foreach ( $property in $config.splat.PSObject.Properties ) { $splat[$property.Name] = $property.Value }
    $splat.customParameters = @{ prompt = "login" }

}
Import-Module $ModulePath -ErrorAction Stop
InModuleScope -ModuleName "PSAuthClient" { 
    Describe "Common functions" { 
        It "Should do valid base64 url encoding" { ConvertTo-Base64urlencoding "https://" | should -be "aHR0cHM6Ly8" } 
        It "Should do valid base64 url decoding" { ConvertFrom-Base64UrlEncoding "aHR0cHM6Ly8" | should -be "https://" } 
        It "Should do valid unix time conversion" { Get-UnixTime | Should -BeOfType System.Int64 }
        It "Should generate random strings of appropriate lenght" { 
            $randomString = Get-RandomString
            $randomString.Length | Should -BeGreaterOrEqual 43
            $randomString.Length | Should -BeLessOrEqual 128
        }
    }
}
Describe "Tools" {
    BeforeAll {
        # fresh id_token for testing
        $id_token = (Invoke-OAuth2AuthorizationEndpoint -uri $config.authorization_endpoint @splat -response_type "id_token" -usePkce:$false).id_token
        $decoded_token = ConvertFrom-JsonWebToken $id_token
    }
    It "ConvertFrom-JsonWebToken should return a valid decoded jwt object" {
        $decoded_token | Should -BeOfType PSCustomObject
        $decoded_token.iss | Should -Not -BeNullOrEmpty
        $decoded_token.sub | Should -Not -BeNullOrEmpty
        $decoded_token.aud | Should -Not -BeNullOrEmpty
        $decoded_token.exp | Should -Not -BeNullOrEmpty
        $decoded_token.iat | Should -Not -BeNullOrEmpty
    }
    It "Test-JsonWebTokenSignature should be able to validate the id_token signature" {
        Test-JsonWebTokenSignature $id_token | Should -Be $true
    }
    It "Get-OidcDiscoveryMetadata should return a PSCustomObject with discovery metadata" {
        $oidc_discoveryMetadata = get-oidcDiscoveryMetadata $decoded_token.iss
        $oidc_discoveryMetadata | Should -BeOfType PSCustomObject
        $oidc_discoveryMetadata.issuer | Should -Not -BeNullOrEmpty
        $oidc_discoveryMetadata.authorization_endpoint | Should -Not -BeNullOrEmpty
        $oidc_discoveryMetadata.token_endpoint | Should -Not -BeNullOrEmpty
        $oidc_discoveryMetadata.jwks_uri | Should -Not -BeNullOrEmpty
    }
    It "Test-JsonWebTokenSignature should differentiate between valid and invalid signatures." {
        # Build Valid and Invalid JWT-Assertions
        $valid_ass = (new-Oauth2JwtAssertion -issuer test -subject test -audience test -client_certificate $config.client_certificate).client_assertion_jwt
        $invalid_ass = (new-Oauth2JwtAssertion -issuer fake -subject test -audience test -client_certificate $config.client_certificate).client_assertion_jwt -replace "[.][a-z0-9_-]+$",".$(($valid_ass -split "[.]")[2])"
        # Attempt to validate JWT-Signatures
        Test-JsonWebTokenSignature $valid_ass -SigningCertificate (get-item $config.client_certificate) | Should -Be $true
        Test-JsonWebTokenSignature -jwtInput $invalid_ass -SigningCertificate (get-item $config.client_certificate) | Should -Be $false
        # Attempt to verify HMAC Hash
        $hmac_ass = new-oauth2JwtAssertion -issuer test -subject test -audience test -client_secret "secret"
        Test-JsonWebTokenSignature -jwtInput $hmac_ass.client_assertion_jwt -client_secret "secret" | Should -Be $true
        Test-JsonWebTokenSignature -jwtInput $hmac_ass.client_assertion_jwt -client_secret "sekret" | Should -Be $false
    }
    It "New-PkceChallenge should return a valid PKCE" {
        $pkce = New-PkceChallenge
        $pkce.code_verifier | Should -Not -BeNullOrEmpty
        $pkce.code_verifier.Length | Should -BeGreaterOrEqual 43
        $pkce.code_verifier.Length | Should -BeLessOrEqual 128
        $pkce.code_challenge | Should -Not -BeNullOrEmpty
        $pkce.code_challenge_method | Should -Be "S256"
    }
}