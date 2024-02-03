---
external help file: PSAuthClient-help.xml
Module Name: PSAuthClient
online version:
schema: 2.0.0
---

# Get-OidcDiscoveryMetadata

## SYNOPSIS
Retreive OpenID Connect Discovery endpoint metadata

## SYNTAX

```powershell
Get-OidcDiscoveryMetadata [[-uri] <Object>]
```

## DESCRIPTION
Retreive OpenID Connect Discovery endpoint metadata.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-OidcDiscoveryMetadata "https://example.org"
Attempts to retreive OpenID Connect Discovery endpoint metadata from 'https://example.org/.well-known/openid-configuration'.
```

### EXAMPLE 2
```powershell
Get-OidcDiscoveryMetadata "https://login.microsoftonline.com/common"
token_endpoint                        : https://login.microsoftonline.com/common/oauth2/token
token_endpoint_auth_methods_supported : {client_secret_post, private_key_jwt, client_secret...}
jwks_uri                              : https://login.microsoftonline.com/common/discovery/keys
response_modes_supported              : {query, fragment, form_post}
subject_types_supported               : {pairwise}
id_token_signing_alg_values_supported : {RS256}
response_types_supported              : {code, id_token, code id_token, token id_tokenÔÇª}
scopes_supported                      : {openid}
issuer                                : https://sts.windows.net/{tenantid}/
microsoft_multi_refresh_token         : True
authorization_endpoint                : https://login.microsoftonline.com/common/oauth2/auth...
device_authorization_endpoint         : https://login.microsoftonline.com/common/oauth2/devi...
http_logout_supported                 : True
frontchannel_logout_supported         : True
end_session_endpoint                  : https://login.microsoftonline.com/common/oauth2/logo...
claims_supported                      : {sub, iss, cloud_instance_name, cloud_instance_host...}
check_session_iframe                  : https://login.microsoftonline.com/common/oauth2/chec...
userinfo_endpoint                     : https://login.microsoftonline.com/common/openid/user...
kerberos_endpoint                     : https://login.microsoftonline.com/common/kerberos
tenant_region_scope                   : 
cloud_instance_name                   : microsoftonline.com
cloud_graph_host_name                 : graph.windows.net
msgraph_host                          : graph.microsoft.com
rbac_url                              : https://pas.windows.net
```

## PARAMETERS

### -uri
The URI of the OpenID Connect Discovery endpoint.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
