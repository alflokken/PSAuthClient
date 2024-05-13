---
external help file: PSAuthClient-help.xml
Module Name: PSAuthClient
online version:
schema: 2.0.0
---

# Invoke-OAuth2AuthorizationEndpoint

## SYNOPSIS
Interact with a OAuth2 Authorization endpoint.

## SYNTAX

```powershell
Invoke-OAuth2AuthorizationEndpoint [-uri] <String> -client_id <String> [-redirect_uri <String>]
 [-response_type <String>] [-scope <String>] [-usePkce <Boolean>] [-response_mode <String>]
 [-customParameters <Hashtable>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Uses WebView2 (embedded browser based on Microsoft Edge) to request authorization, this ensures support for modern web pages and capabilities like SSO, Windows Hello, FIDO key login, etc

OIDC and OAUTH2 Grants such as Authorization Code Flow with PKCE, Implicit Flow (including form_post) and Hybrid Flows are supported

## EXAMPLES

### EXAMPLE 1
```powershell
Invoke-OAuth2AuthorizationEndpoint -uri "https://acc.spotify.com/authorize" -client_id "2svXwWbFXj" -scope "user-read-currently-playing" -redirect_uri "http://localhost"
code_verifier                  xNTKRgsEy_u2Y.PQZTmUbccYd~gp7-5v4HxS7HVKSD2fE.uW_yu77HuA-_sOQ...
redirect_uri                   https://localhost
client_id                      2svXwWbFXj
code                           AQDTWHSP6e3Hx5cuJh_85r_3m-s5IINEcQZzjAZKdV4DP_QRqSHJzK_iNB_hN...
```

A request for user authorization is sent to the /authorize endpoint along with a code_challenge, code_challenge_method and state param. 
If successful, the authorization server will redirect back to the redirect_uri with a code which can be exchanged for an access token.

### EXAMPLE 2
```powershell
Invoke-OAuth2AuthorizationEndpoint -uri "https://example.org/oauth2/authorize" -client_id "0325" -redirect_uri "http://localhost" -scope "user.read" -response_type "token" -usePkce:$false -customParameters @{ login = "none" }
expires_in                     4146
expiry_datetime                01.02.2024 10:56:06
scope                          User.Read profile openid email
session_state                  5c044a21-543e-4cbc-a94r-d411ddec5a87
access_token                   eyJ0eXAiQiJKV1QiLCJub25jZSI6InAxYTlHksH6bktYdjhud3VwMklEOGtUM...
token_type                     Bearer
```

Implicit Grant, will return a access_token if successful.

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
The identifier of the client at the authorization server.

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

### -redirect_uri
The client callback URI for the authorization response.

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

### -response_type
Tells the authorization server which grant to execute.
Default is code.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Code
Accept pipeline input: False
Accept wildcard characters: False
```

### -scope
One or more space-separated strings indicating which permissions the application is requesting.

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

### -usePkce
Proof Key for Code Exchange (PKCE) improves security for public clients by preventing and authorization code attacks.
Default is $true.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -response_mode
OPTIONAL Informs the Authorization Server of the mechanism to be used for returning Authorization Response.
Determined by response_type, if not specified.

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

### -customParameters
Hashtable with custom parameters added to the request uri (e.g.
domain_hint, prompt, etc.) both the key and value will be url encoded.
Provided with state, nonce or PKCE keys these values are used in the request (otherwise values are generated accordingly).

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

### System.Collections.Hashtable
## NOTES

## RELATED LINKS
