---
external help file: PSAuthClient-help.xml
Module Name: PSAuthClient
online version:
schema: 2.0.0
---

# Invoke-OAuth2TokenEndpoint

## SYNOPSIS
Token Exchange by OAuth2.0 Token Endpoint interaction.

## SYNTAX

### code (Default)
```powershell
Invoke-OAuth2TokenEndpoint [-uri] <String> [-client_id <String>] [-redirect_uri <String>] [-scope <String>]
 [-code <String>] [-code_verifier <String>] [-client_secret <Object>] [-nonce <String>]
 [-customHeaders <Hashtable>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### refresh
```powershell
Invoke-OAuth2TokenEndpoint [-uri] <String> [-client_id <String>] [-redirect_uri <String>] [-scope <String>]
 [-client_secret <Object>] [-client_auth_method <Object>] [-client_certificate <Object>] [-nonce <String>]
 -refresh_token <Object> [-customHeaders <Hashtable>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### device_code
```powershell
Invoke-OAuth2TokenEndpoint [-uri] <String> [-client_id <String>] -device_code <String>
 [-customHeaders <Hashtable>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### client_secret
```powershell
Invoke-OAuth2TokenEndpoint [-uri] <String> [-client_id <String>] [-redirect_uri <String>] [-scope <String>]
 [-code <String>] [-code_verifier <String>] -client_secret <Object> [-client_auth_method <Object>]
 [-nonce <String>] [-customHeaders <Hashtable>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### client_certificate
```powershell
Invoke-OAuth2TokenEndpoint [-uri] <String> [-client_id <String>] [-redirect_uri <String>] [-scope <String>]
 [-code <String>] [-code_verifier <String>] -client_certificate <Object> [-nonce <String>]
 [-customHeaders <Hashtable>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Forge and send token exchange requests to the OAuth2.0 Token Endpoint.

## EXAMPLES

### EXAMPLE 1
```powershell
$code = Invoke-OAuth2AuthorizationEndpoint -uri $authorization_endpoint @splat
PS> Invoke-OAuth2TokenEndpoint -uri $token_endpoint @code
token_type      : Bearer
scope           : User.Read profile openid email
expires_in      : 4948
ext_expires_in  : 4948
access_token    : eyJ0eXAiOiJKV1QiLCJujHu5ZSI6IllQUWFERGtkVEczUjJIYm5tWFlhOG1QbHk1ZTlwckJybm...
refresh_token   : 0.AUcAjvFfm8BTokWLwpwMkH65xiGBP5hz2ZpErJuc3chlhOUNAVw.AgABAAEAAAAmoFfGtYxv...
id_token        : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2...
expiry_datetime : 01.02.2024 12:51:33
```

Invokes the Token Endpoint by passing parameters from the authorization endpoint response such as code, code_verifier, nonce, etc.

### EXAMPLE 2
```powershell
Invoke-OAuth2TokenEndpoint -uri $token_endpoint -scope ".default" -client_id "123" -client_secret "secret"
token_type      : Bearer
expires_in      : 3599
ext_expires_in  : 3599
access_token    : eyJ0eXAiOiJKV1QikjY6b25jZSI6IkZ4YTZ4QmloQklGZjFPT0FqQZQ4LTl5WUEtQnpqdXNzTn...
expiry_datetime : 01.02.2024 12:33:01
```

Client authentication using client_secret_post

### EXAMPLE 3
```powershell
Invoke-OAuth2TokenEndpoint -uri $token_endpoint -scope ".default" -client_id "123" "Cert:\CurrentUser\My\8kge399dddc5521e04e34ac19fe8f8759ba021b8"
token_type      : Bearer
expires_in      : 3599
ext_expires_in  : 3599
access_token    : eyJ0eXYiOiJKV1QiLCJusk6jZSI6IlNkYU9lOTdtY0NqS0g1VnRURjhTY3JSMEgwQ0hje24fR1...
expiry_datetime : 01.02.2024 12:36:17
```

Client authentication using private_key_jwt

## PARAMETERS

### -uri
Authorization endpoint URL.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -client_id
The identifier of the client at the authorisation server.
(required if no other client authentication is present)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -redirect_uri
The client callback URI for the response.
(required if it was included in the initial authorization request)

```yaml
Type: String
Parameter Sets: code, refresh, client_secret, client_certificate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -scope
One or more space-separated strings indicating which permissions the application is requesting.

```yaml
Type: String
Parameter Sets: code, refresh, client_secret, client_certificate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -code
Authorization code received from the authorization server.

```yaml
Type: String
Parameter Sets: code, client_secret, client_certificate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -code_verifier
Code_verifier, required if code_challenge was used in the authorization request (PKCE).

```yaml
Type: String
Parameter Sets: code, client_secret, client_certificate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -device_code
Device verification code received from the authorization server.

```yaml
Type: String
Parameter Sets: device_code
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -client_secret
client credential as string or securestring

```yaml
Type: Object
Parameter Sets: code, refresh
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Object
Parameter Sets: client_secret
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -client_auth_method
OPTIONAL client (secret) authentication method.
(default: client_secret_post)

```yaml
Type: Object
Parameter Sets: refresh, client_secret
Aliases:

Required: False
Position: Named
Default value: Client_secret_post
Accept pipeline input: False
Accept wildcard characters: False
```

### -client_certificate
client credential as x509certificate2, RSA Private key or cert location 'Cert:\CurrentUser\My\THUMBPRINT'

```yaml
Type: Object
Parameter Sets: refresh
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Object
Parameter Sets: client_certificate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -nonce
OPTIONAL nonce value used to associate a Client session with an ID Token, and to mitigate replay attacks.

```yaml
Type: String
Parameter Sets: code, refresh, client_secret, client_certificate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -refresh_token
Refresh token received from the authorization server.

```yaml
Type: Object
Parameter Sets: refresh
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -customHeaders
Hashtable with custom headers to be added to the request uri (e.g.
User-Agent, Origin, Referer, etc.).

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
