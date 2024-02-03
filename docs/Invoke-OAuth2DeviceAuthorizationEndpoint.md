---
external help file: PSAuthClient-help.xml
Module Name: PSAuthClient
online version:
schema: 2.0.0
---

# Invoke-OAuth2DeviceAuthorizationEndpoint

## SYNOPSIS
OAuth2.0 Device Authorization Endpoint Interaction

## SYNTAX

```powershell
Invoke-OAuth2DeviceAuthorizationEndpoint [-uri] <String> -client_id <String> [-scope <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get a unique device verification code and an end-user code from the device authorization endpoint, which then can be used to request tokens from the token endpoint.

## EXAMPLES

### EXAMPLE 1
```powershell
Invoke-OAuth2DeviceAuthorizationEndpoint -uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/devicecode" -client_id $splat.client_id -scope $splat.scope
user_code        : L8EFTXRY3
device_code      : LAQABAAEAAAAmoFfGtYxvRrNriQdPKIZ-2b64dTFbGcmRF3rSBagHQGtBcyz0K_XV8ltq-nXz...
verification_uri : https://microsoft.com/devicelogin
expires_in       : 900
interval         : 5
message          : To sign in, use a web browser to open the page https://microsoft.com/devi...
```

## PARAMETERS

### -uri
The URI of the OAuth2.0 Device Authorization endpoint.

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
The client identifier.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -scope
The scope of the access request.

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
