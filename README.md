# PSAuthClient
PSAuthClient is a flexible PowerShell OAuth2.0/OpenID Connect (OIDC) Client.
* Support for a [wide range of grants](#examples-of-openid-connect-oidc-and-oauth20-grants).
* Uses [WebView2](https://learn.microsoft.com/en-us/microsoft-edge/webview2/) to support modern web experiences where interaction is required.
* Includes [useful tools](#Tools) for decoding tokens and validating jwt signatures.
<br>

![Auth client in use](docs/images/spotify_auth.gif)

# Install
The module is available from PSGallery, alternatively [download]() and place the module in '$home\Documents\WindowsPowerShell\Modules or
'$env:ProgramFiles\PowerShell\Modules' manually.
```powershell
Install-Module PSAuthClient -Scope:CurrentUser
```

# Usage
See links for function documentation, usage and examples.
| Function | Description |
| -------- | ----------- |
| [Invoke-OAuth2AuthorizationEndpoint](/docs/Invoke-OAuth2AuthorizationEndpoint.md) | Uses WebView2 (embedded browser based on Microsoft Edge) to request authorization, this ensures support for modern web pages and capabilities like SSO, Windows Hello, FIDO key login, etc. | 
| [Invoke-OAuth2DeviceAuthorizationEndpoint](/docs/Invoke-OAuth2DeviceAuthorizationEndpoint.md) | Get device verification code and end-user code from the device authorization endpoint, which then can be used to request tokens from the token endpoint. |
| [Invoke-OAuth2TokenEndpoint](docs/Invoke-OAuth2TokenEndpoint.md) | Build and send token exchange requests to the OAuth2.0 Token Endpoint. |
| [Get-OidcConfigurationMetadata](docs/Get-OidcDiscoveryMetadata.md) | Retreive OpenID Connect Discovery endpoint metadata. |
| [ConvertFrom-JsonWebToken](docs/ConvertFrom-JsonWebToken.md) | Convert (decode) a JSON Web Token (JWT) to a PowerShell object. |
| [Test-JsonWebTokenSignature](docs/Test-JsonWebTokenSignature.md) | Attempt to validate the signature of a JSON Web Token (JWT) by using the issuer discovery metadata to get the signing certificate. (If no signing certificate or secret was provided.) |
| [New-PkceChallenge](docs/New-PkceChallenge.md) | Generate code_verifier and code_challenge for PKCE (authorization code flow). |
| [New-Oauth2JwtAssertion](docs/New-Oauth2JwtAssertion.md) | Create and sign JWT Assertions using either a client_certificate (x509certificate2 or RSA Private key) or client_secret (for HMAC-based signature).|
| [Clear-WebView2Cache](docs/Clear-WebView2Cache.md) | Removes PSAuthClient WebView2 user data folder (UDF) which is used to store browser data such as cookies, permissions and cached resources.|


<br>

# Examples of OpenID Connect (OIDC) and OAuth2.0 Grants

OpenID Connect is an extension of OAuth2 that adds an identity layer to the authorization framework. This allows a client to verify the identity of the user and obtain basic profile information. OIDC grants contains 'openid' scope and the identity provider will return a 'id_token' with user information (claims). 

<details>
<summary>Parameters that are used (and modified) troughout the examples below.</summary>

```powershell
$authorization_endpoint = "https://login.microsoftonline.com/example.org/oauth2/v2.0/authorize"
$token_endpoint = "https://login.microsoftonline.com/example.org/oauth2/v2.0/token"

$splat = @{
    client_id = "5eda97cf-2963-41e9-bea0-b6ba2bbf8f99"
    scope = "user.read openid offline_access"
    redirect_uri = "https://login.microsoftonline.com/common/oauth2/nativeclient"
    customParameters = @{ 
        prompt = "none"
    }
}
```
<br>
</details>
<br>
<details>
<summary><b>Authorization Code Grant with Proof Key for Code Exchange (PKCE)</b></summary>

Example
```powershell
$code = Invoke-OAuth2AuthorizationEndpoint -uri $authorization_endpoint @splat

client_id                      5eda97cf-2963-41e9-bea0-b6ba2bbf8f99
code_verifier                  ig0Sly4Kdjc_e77Zsp5..PKi.TbqzSNz_CEKsamyPRI5~uRr4_
nonce                          o180HoFS2k5y0gj.spbYos.IPUS8-SqSf4cx0Z7x
redirect_uri                   https://login.microsoftonline.com/common/oauth2/nativeclient
code                           0.AUcAjvFfm8BTokWLwpwMj2CyxiGBP5hz2ZpErJuc3chlhOUNAVw.AgABAAIAAAA...

$token = Invoke-OAuth2TokenEndpoint -uri $token_endpoint @code

token_type      : Bearer
scope           : User.Read profile openid email
expires_in      : 5340
ext_expires_in  : 5340
access_token    : eyJ0eXAiOiJKV1QiLCJub25jZSI6IlhFMjJvBXRyVDBkQ1Z1cG7zbEFJQk1kU1RxLS5xQUppS3Fpbr...
refresh_token   : 0.AUcAjvFfm8BTokWLwpwMj2CyxiGBP5hz2ZpErJuc3chlhOUNAVw.AgABAAEAAAAmoFfGtYxvRrNr...
id_token        : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2hIYm...
expiry_datetime : 31.01.2024 14:11:08


```
</details>

<details>
<summary><b>Authorization Code Grant</b></summary>

Example
```powershell
$code = Invoke-OAuth2AuthorizationEndpoint -uri $authorization_endpoint @splat -usePkce:$false

nonce                          UYhqAG~GLvZqGj4hnlTkYFJY9LVcS9TrWiq.8n8Vu
redirect_uri                   https://login.microsoftonline.com/common/oauth2/nativeclient
client_id                      5eda97cf-2963-41e9-bea0-b6ba2bbf8f99
code                           0.AUcAjvFfm8BTokWLwpwMj2CyxiGBP5hz2ZpErJuc3chlhOUNAVw.AgABAAmoFfG...

$token = Invoke-OAuth2TokenEndpoint -uri $token_endpoint @code

token_type      : Bearer
scope           : User.Read profile openid email
expires_in      : 3848
ext_expires_in  : 3848
access_token    : eyJ0eXAiOiJKV1QiLCJub62jZSI6ImhDRkwxMjVHdE85SmNqS0NWMFZQLWxTd2Z0Zm12LXFsV2VDR0...
refresh_token   : 0.AUcAjvFfm8BTokWLwpwMkJCyxiGBP5hz2ZpErJuc3chlhOUNAVw.AgABAAEAAAAmoFfGtYxjHyNf...
id_token        : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQndpaU547ZT2hI...
expiry_datetime : 31.01.2024 14:05:18
```
</details>

<details>
<summary><b>Authorization Code Grant with Client Authentication (secret)</b></summary>

Example
```powershell
$splat.redirect_uri = "https://localhost/web"
$code = Invoke-OAuth2AuthorizationEndpoint -uri $authorization_endpoint @splat 

client_id                      5eda97cf-2963-41e9-bea0-b6ba2bbf8f99
code_verifier                  jWe-ecfnqZ.weAxbb-qHiZ3oe7LZ-tEyWq~7UB9RcNfZn65Xq2zPO7-8rv-5tp24p...
nonce                          HRBD6BuH9PQM2_Kmuqj6KTranVVcuL80fsEpll-9nppaZp0H3CQaYhaqQ2VqUV8
redirect_uri                   https://localhost/web
code                           0.AUcAjvFfm8BTokWLwpwMj2CyxiGBP5hz2ZpErJuc3chlhOUNAVw.AgABAAIAAAm...

$token = Invoke-OAuth2TokenEndpoint -uri $token_endpoint @code -client_secret $client_secret

token_type      : Bearer
scope           : User.Read profile openid email
expires_in      : 4069
ext_expires_in  : 4069
access_token    : eyJ0eXAiOiJKG1QqLCJub25jZSI5IllOTzdpTmdXZnMtSmSSY1hpZk45bTdoa2E0WnNpWFY5ckswen...
refresh_token   : 0.AUcAjvFfmC9TokWLwpwMj2CyxiGBP5hz2ZpRrJuc3chlhOUGAVw.AgABAAEAAAAmoFfGtYxvRrNf...
id_token        : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2hIYm...
expiry_datetime : 31.01.2024 14:28:58
```
</details>

<details>
<summary><b>Refresh Token Grant</b></summary>

Example
```powershell
$token = Invoke-OAuth2TokenEndpoint -uri $token_endpoint -refresh_token $token.refresh_token -client_id $splat.client_id -scope $splat.scope -nonce $code.nonce

token_type      : Bearer
scope           : User.Read profile openid email
expires_in      : 3951
ext_expires_in  : 3951
access_token    : eyJ0eXAiOiJKR1QiLCJsf52jZSI6IjdCbkI2VDc5OGJZVlh3ZHdIRWVOMGducUVKQVBEUnBPcTZhMm...
refresh_token   : 0.AUcAjvFfm1BTokWLkjrMj3CyxiGBP5hz4ZpErJuc3chlhOUNAVw.AgABAAEAAAAmoFfGtDxvRrNa...
id_token        : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQndsapaU5ZT2hI...
expiry_datetime : 31.01.2024 14:16:56
```
</details>

<details>
<summary><b>Client Credentials Grant (client_secret_basic)</b></summary>

Example
```powershell
$splat.Remove("customParameters")
$splat.scope = ".default"
$token = Invoke-OAuth2TokenEndpoint -uri $token_endpoint @splat -client_secret (Invoke-Cache -keyName "PSC_Test-ClientSecret") -client_auth_method client_secret_basic

token_type      : Bearer
expires_in      : 3599
ext_expires_in  : 3599
access_token    : eyJ0eXAiOiJKV1DiLCJub25jZSI3IjUtQjB0bXBSNHhzYWtJSW8wOFY5ejFGVGRTWDF5blZfalNVX2...
expiry_datetime : 31.01.2024 14:14:06
```
</details>

<details>
<summary><b>Client Credentials Grant (client_secret_post)</b></summary>

```powershell
$token = Invoke-OAuth2TokenEndpoint -uri $token_endpoint @splat -client_secret (Invoke-Cache -keyName "PSC_Test-ClientSecret" -asSecureString)

token_type      : Bearer
expires_in      : 3599
ext_expires_in  : 3599
access_token    : eyJ0eXAiOiJKV1QiGCJub25jZSI3ImtIeW5MWTNyUjdja0lZd1RTQWVSRi1yRnVYYUx0Y6VaU11NEF...
expiry_datetime : 31.01.2024 14:16:10
```
</details>

<details>
<summary><b>Client Credentials Grant (client_secret_jwt)</b></summary>

Example
```powershell
# Microsoft Graph DOES NOT support client_secret_jwt, but if they did, this is how you would do it.
$token = Invoke-OAuth2TokenEndpoint -uri $token_endpoint @splat -client_secret $client_secret -client_auth_method "client_secret_jwt"

error          error_description
-----          -----------------
invalid_client AADSTS5002723: Invalid JWT token. No certificate SHA-1 thumbprint, certificate SH...

```
</details>

<details>
<summary><b>Client Credentials Grant certificate (private_key_jwt)</b></summary>

Example
```powershell
$token = Invoke-OAuth2TokenEndpoint -uri $token_endpoint @splat -client_certificate "Cert:\CurrentUser\My\8ade399dddc5973e04e34ac19fe8f8759ba059b8"

token_type      : Bearer
expires_in      : 3599
ext_expires_in  : 3599
access_token    : eyJ0eXAiOiJKV1QiLCJub21jZSI2InpBUjQ6UTBRc7dzYkcxOVJibQ032s2UUxrckZUcm9BYmwgdh0...
expiry_datetime : 31.01.2024 14:20:03

```
</details>

<details>
<summary><b>Implicit Grant (OAuth2.0)</b></summary>

Example
```powershell
$splat.redirect_uri = "https://localhost/spa"
$splat.scope = "User.Read"
$token = Invoke-OAuth2AuthorizationEndpoint -uri $authorization_endpoint @splat -response_type "token" -usePkce:$false

expires_in                     4371
expiry_datetime                31.01.2024 14:39:19
scope                          User.Read profile openid email
session_state                  5c044a56-543e-4bcc-a94f-d411ddec5a87
access_token                   eyJ0eXAiOiJKV1QiLCJkj76jZSI6InlaZzBmU1NGV1M1UmllaFRHc01jMWJkSFNIZ...
token_type                     Bearer
```
</details>

<details>
<summary><b>Implicit Grant (OIDC)</b></summary>

Example
```powershell
$token = Invoke-OAuth2AuthorizationEndpoint -uri $authorization_endpoint @splat -response_type "token id_token" -usePkce:$false

nonce                          NtKwrnSuV7xQQiya.jNXF940RQkS0OMlTcQDCOOgJay8a2qi0.MO4KKX8xc-XWUa
expires_in                     4949
id_token                       eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQ...
expiry_datetime                31.01.2024 14:46:35
scope                          User.Read profile openid email
session_state                  5c044a56-543e-4bcc-a94f-d411ddec5a87
access_token                   eyJ0eXAiOiJKV1QiLCJub51jZSI6Ik2saWhWbkdCMzNYUnI0VTF5VUVYLXA0Zkp6K...
token_type                     Bearer
```
</details>

<details>
<summary><b>Hybrid Grant</b></summary>

Example
```powershell
$splat.scope = "user.read openid offline_access"
$splat.redirect_uri = "http://localhost"
$splat.usePkce = $true
$token = Invoke-OAuth2AuthorizationEndpoint -uri $authorization_endpoint  @splat -response_type "code id_token"

nonce                          7B61P-.ST87WdKZ9TPF~1a5sMkPs.atxj8sBCmY2mHHfEKRotmK37dxDl
code_verifier                  w6Fvr5LTkex0k.aRJhL9rZeEDNSO5sdc8zeQYlstYJuZ2K9ck2azZ~Luxeaw2CCSd...
id_token                       eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQ...
client_id                      5eda97cf-2963-41e9-bea0-b6ba2bbf8f99
session_state                  5c044a56-543e-4bcc-a94f-d411ddec5a87
redirect_uri                   http://localhost
code                           0.AUcAjvFfm8BTokWLwpwMj2CyxiGBP5hz2ZpErJuc3chlhOUNAVw.AgABAAAAAmo...

$token.Remove("id_token"); $token.Remove("session_state")
$tokens = Invoke-OAuth2TokenEndpoint -uri $token_endpoint @token

nonce                          da1EE3-RRVJO.fFeCEw2TvG7hK46AWFWHJCOBeRfnJ6o
code_verifier                  ~4fYq2QcXlSIZN_vZ7pnKsO5VZ0Pq39hsdQOAziqDqsGNL-JGP~
client_id                      5eda97cf-2963-41e9-bea0-b6ba2bbf8f99
redirect_uri                   http://localhost
code                           0.AUcAjvFfm8BTokWLwpwMj2CyxiGBP5hz2ZpErJuc3chlhOUNAVw.AgABAAIAAAA...
```
</details>

<details>
<summary><b>Implicit Flow (by Form_Post)</b></summary>

Example
```powershell
$splat.redirect_uri = "http://localhost:5001/"
$customParameters = @{ 
    prompt = "none" # login, none, consent, select_account
}
$token = Invoke-OAuth2AuthorizationEndpoint -uri $authorization_endpoint  @splat -response_type "code id_token" -response_mode "form_post"

nonce                          iOJ6n7jBlYAL_TrYlFjfKwOsPklX1-4iR
code_verifier                  j1v4ZEjF4AE.lMfsQ36UzF6OoBp.zwuJ7Qkez9XQX~4lGo9pnxxtN.P4ulFhkwBaZ...
id_token                       eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQ...
client_id                      5eda97cf-2963-41e9-bea0-b6ba2bbf8f99
session_state                  5c044a56-543e-4bcc-a94f-d411ddec5a87
redirect_uri                   http://localhost:5001/
code                           0.AUcAjvFfm8BTokWLwpwMj2CyxiGBP5hz2ZpErJuc3chlhOUNAVw.AgABAAIAmoF...


$token.Remove("id_token"); $token.Remove("session_state")
$tokens = Invoke-OAuth2TokenEndpoint -uri $token_endpoint @token

token_type      : Bearer
scope           : User.Read profile openid email
expires_in      : 4840
ext_expires_in  : 4840
access_token    : eyJ0eXAiOiJKV1QiLCJub55jZSI6IlRsTFVNS5MyaEpscDNfNzKH75GXMXI0WndKMnlKJSJzFdzJEb...
refresh_token   : 0.AUcAjvFfm8BTokSLwpwMj2CyxiGBP5kH76pErJuc3chlhOUNAVw.AgABAAEAPKIZ-AgDs_wSA9P9...
id_token        : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2hIYm...
expiry_datetime : 31.01.2024 14:54:54
```
</details>

<details>
<summary><b>Device Code Grant</b></summary>

Example
```powershell
$deviceCode = Invoke-OAuth2DeviceAuthorizationEndpoint -uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/devicecode" -client_id $splat.client_id -scope $splat.scope

user_code        : L8EFTXRY3
device_code      : LAQABAAEAAAAmoFfGtYxvRrNriQdPKIZ-2b64dTFbGcmRF3rSBagHQGtBcyz0K_XV8ltq-nXz8Ks6...
verification_uri : https://microsoft.com/devicelogin
expires_in       : 900
interval         : 5
message          : To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the co...

# Pop interactive browser
Invoke-WebView2 -uri "https://microsoft.com/devicelogin" -UrlCloseConditionRegex "//appverify$" -title "Device Code Flow" | Out-Null

# After user-interaction has been completed.
$token = Invoke-OAuth2TokenEndpoint -uri $token_endpoint -device_code $deviceCode.device_code -client_id $splat.client_id

token_type      : Bearer
scope           : User.Read profile openid email
expires_in      : 5320
ext_expires_in  : 5320
access_token    : eyJ0eXAiOiJKV1QiKH6Gb25jZSI5IjlzanppVWtNSlkR4WxfWjBRWFJRZUl4TEdyaDBad05TQ01sQ1...
refresh_token   : 0.AUcAjvFfm8BlORWLwpwMj2CyxiGBP5hz2ZpErkU62chlhOUNAVw.AgABAAEAAAAmoFfGtYxvRrlK...
id_token        : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2hIYm...
expiry_datetime : 31.01.2024 15:07:19


```
</details>

<details>
<summary><b>Resource Owner Password Flow (ROPC)</b></summary>
no thanks, tom hanks.
</details>

# Tools

<details>
<summary><b>OIDC Discovery</b></summary>

Retreive OpenID Connect Discovery metadata.
```powershell
Get-OidcDiscoveryMetadata "https://login.microsoftonline.com/common"

token_endpoint                        : https://login.microsoftonline.com/common/oauth2/token
token_endpoint_auth_methods_supported : {client_secret_post, private_key_jwt, client_secret_basic}
jwks_uri                              : https://login.microsoftonline.com/common/discovery/keys
response_modes_supported              : {query, fragment, form_post}
subject_types_supported               : {pairwise}
id_token_signing_alg_values_supported : {RS256}
response_types_supported              : {code, id_token, code id_token, token id_tokenÔÇª}
scopes_supported                      : {openid}
issuer                                : https://sts.windows.net/{tenantid}/
microsoft_multi_refresh_token         : True
authorization_endpoint                : https://login.microsoftonline.com/common/oauth2/authorize
device_authorization_endpoint         : https://login.microsoftonline.com/common/oauth2/devicecode
http_logout_supported                 : True
frontchannel_logout_supported         : True
end_session_endpoint                  : https://login.microsoftonline.com/common/oauth2/logout
claims_supported                      : {sub, iss, cloud_instance_name, cloud_instance_host_name}
check_session_iframe                  : https://login.microsoftonline.com/common/oauth2/checksession
userinfo_endpoint                     : https://login.microsoftonline.com/common/openid/userinfo
kerberos_endpoint                     : https://login.microsoftonline.com/common/kerberos
tenant_region_scope                   : 
cloud_instance_name                   : microsoftonline.com
cloud_graph_host_name                 : graph.windows.net
msgraph_host                          : graph.microsoft.com
rbac_url                              : https://pas.windows.net


```

</details>

<details>
<summary><b>Decode JWT</b></summary>

Convert (decode) a JSON Web Token (JWT) to a PowerShell object.
```powershell
PS> ConvertFrom-JsonWebToken "ew0KICAidHlwIjogIkpXVCIsDQogICJhbGciOiAiUlMyNTYiDQp9.ew0KICAi..."

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



```

</details>

<details>
<summary><b>Validate JWT Signature</b></summary>

Attempt to validate the signature of a JSON Web Token (JWT) by using the issuer discovery metadata to get the signing certificate. (If no signing certificate or secret was provided.)

```powershell
PS> Test-JsonWebTokenSignature -jwtInput $jwt
True
```

</details>

<details>
<summary><b>Build JWT Assertions</b></summary>

Create and sign JWT Assertions using either a client_certificate (x509certificate2 or RSA Private key) or client_secret (for HMAC-based signature).

```powershell
PS> New-Oauth2JwtAssertion -issuer "test" -subject "test1" -audience "test2" -jwtId "123" -customClaims @{ claim1 = "test" } -client_secret "secret"

client_assertion_jwt           ew0KICAiYWxnIjogIlJTMjU2IiwNCiAgInR5cCI6ICJKV1QiDQp9.ew0KICAianRp...
client_assertion_type          urn:ietf:params:oauth:client-assertion-type:jwt-bearer
header                         @{alg=RS256; typ=JWT}
payload                        @{jti=123; claim1=test; aud=test2; exp=1706793151; nbf=170679285...}
```

</details>

<details>
<summary><b>Generate a PKCE Challenge</b></summary>

Generate code_verifier and code_challenge for PKCE (authorization code flow).

```powershell
PS> New-PkceChallenge

code_verifier                  Vpq2YXOsD~1DRM-jBPR6bt8R-3dWQAHNLVLUIDxh7SkWpOT3A0grpenqKne5rAHcVKsTi-ya8-lGBxJ0NS7zavdcFbfdN0yFQ5kYOFbWBh3
code_challenge                 TW-3r-6mxRWjhkkxmYOabLlwIQ0JkQ0ndxzOSLJvCoU
code_challenge_method          S256
```

</details>