---
external help file: PSAuthClient-help.xml
Module Name: PSAuthClient
online version:
schema: 2.0.0
---

# Test-JsonWebTokenSignature

## SYNOPSIS
Test the signature of a JSON Web Token (JWT)

## SYNTAX

### certificate (Default)
```powershell
Test-JsonWebTokenSignature [-jwtInput] <Object> [-SigningCertificate <X509Certificate2>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### client_secret
```powershell
Test-JsonWebTokenSignature [-jwtInput] <Object> -client_secret <Object> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Automatically attempt to test the signature of a JSON Web Token (JWT) by using the issuer discovery metadata to get the signing certificate if no signing certificate or secret was provided.

## EXAMPLES

### EXAMPLE 1
```powershell
Test-JsonWebTokenSignature -jwtInput $jwt
```

Decodes the JWT and attempts to verify the signature using the issuer discovery metadata to get the signing certificate if no signing certificate or secret was provided.

### EXAMPLE 2
```powershell
Test-JsonWebTokenSignature -jwtInput $jwt -SigningCertificate $cert
```

Decodes the JWT and attempts to verify the signature using the provided certificate.

### EXAMPLE 3
```powershell
Test-JsonWebTokenSignature -jwtInput $jwt -client_secret $secret
```

Decodes the JWT and attempts to verify the signature using the provided client secret.

## PARAMETERS

### -jwtInput
The JSON Web Token (string) to be must be in the form of a valid JWT.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SigningCertificate
X509Certificate2 object to be used for RSA signature verification.

```yaml
Type: X509Certificate2
Parameter Sets: certificate
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -client_secret
Client secret to be used for HMAC signature verification.

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

### System.Boolean
## NOTES

## RELATED LINKS
