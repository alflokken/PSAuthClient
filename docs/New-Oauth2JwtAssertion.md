---
external help file: PSAuthClient-help.xml
Module Name: PSAuthClient
online version:
schema: 2.0.0
---

# New-Oauth2JwtAssertion

## SYNOPSIS
Create a JWT Assertion for OAuth2.0 Client Authentication.

## SYNTAX

### private_key_jwt (Default)
```powershell
New-Oauth2JwtAssertion [-issuer] <String> [-subject] <String> [-audience] <String> [[-jwtId] <String>]
 [-customClaims <Hashtable>] -client_certificate <Object> [-key_id <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### client_secret_jwt
```powershell
New-Oauth2JwtAssertion [-issuer] <String> [-subject] <String> [-audience] <String> [[-jwtId] <String>]
 [-customClaims <Hashtable>] -client_secret <Object> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Create a JWT Assertion for OAuth2.0 Client Authentication.

## EXAMPLES

### EXAMPLE 1
```powershell
New-Oauth2JwtAssertion -issuer $client_id -subject $client_id -audience $oidcDiscoveryMetadata.token_endpoint -client_certificate $cert
```

client_assertion_jwt          ew0KICAidHlwIjogIkpXVCIsDQogICJhbGciOiAiUlMyNTYiDQp9.ew0KICAia...
client_assertion_type          urn:ietf:params:oauth:client-assertion-type:jwt-bearer
header                         @{typ=JWT; alg=RS256}
payload                        @{iss=PSAuthClient; nbf=1706785754; iat=1706785754; sub=PSAu...}

## PARAMETERS

### -issuer
iss, must contain the client_id of the OAuth Client.

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

### -subject
sub, must contain the client_id of the OAuth Client.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -audience
aud, should be the URL of the Authorization Server's Token Endpoint.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -jwtId
jti, unique token identifier.
Random GUID by default.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: [string]([guid]::NewGuid())
Accept pipeline input: False
Accept wildcard characters: False
```

### -customClaims
Hashtable with custom claims to be added to the JWT payload (assertion).

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

### -client_certificate
Location Cert:\CurrentUser\My\THUMBPRINT, x509certificate2 or RSA Private key.

```yaml
Type: Object
Parameter Sets: private_key_jwt
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -key_id
kid, key identifier for assertion header

```yaml
Type: Object
Parameter Sets: private_key_jwt
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -client_secret
clientsecret for HMAC signature

```yaml
Type: Object
Parameter Sets: client_secret_jwt
Aliases:

Required: True
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
