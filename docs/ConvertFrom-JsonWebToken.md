---
external help file: PSAuthClient-help.xml
Module Name: PSAuthClient
online version:
schema: 2.0.0
---

# ConvertFrom-JsonWebToken

## SYNOPSIS
Convert (decode) a JSON Web Token (JWT) to a PowerShell object.

## SYNTAX

```powershell
ConvertFrom-JsonWebToken [-jwtInput] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Convert (decode) a JSON Web Token (JWT) to a PowerShell object.

## EXAMPLES

### EXAMPLE 1
```powershell
ConvertFrom-JsonWebToken "ew0KICAidHlwIjogIkpXVCIsDQogICJhbGciOiAiUlMyNTYiDQp9.ew0KICAiZXhwIjogMTcwNjc4NDkyOSwNCiAgImVjaG8..."
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

## PARAMETERS

### -jwtInput
The JSON Web Token (string) to be must be in the form of a valid JWT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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
