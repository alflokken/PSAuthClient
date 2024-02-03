function Invoke-OAuth2DeviceAuthorizationEndpoint {
    <#
    .SYNOPSIS
    OAuth2.0 Device Authorization Endpoint Interaction
    .DESCRIPTION
    Get a unique device verification code and an end-user code from the device authorization endpoint, which then can be used to request tokens from the token endpoint.
    .PARAMETER uri
    The URI of the OAuth2.0 Device Authorization endpoint.
    .PARAMETER client_id
    The client identifier.
    .PARAMETER scope
    The scope of the access request.
    .EXAMPLE
    PS> Invoke-OAuth2DeviceAuthorizationEndpoint -uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/devicecode" -client_id $splat.client_id -scope $splat.scope
    user_code        : L8EFTXRY3
    device_code      : LAQABAAEAAAAmoFfGtYxvRrNriQdPKIZ-2b64dTFbGcmRF3rSBagHQGtBcyz0K_XV8ltq-nXz...
    verification_uri : https://microsoft.com/devicelogin
    expires_in       : 900
    interval         : 5
    message          : To sign in, use a web browser to open the page https://microsoft.com/devi...
    #>
    [Alias('Invoke-DeviceAuthorizationEndpoint','deviceauth')]
    param (
        [parameter( Position = 0, Mandatory = $true, HelpMessage="Token endpoint URL.")]
        [string]$uri,
        [parameter( Mandatory = $true )]
        [string]$client_id,
        [parameter( Mandatory = $false )]
        [string]$scope
    )
    $requestBody = @{}
    $requestBody.client_id = $client_id
    if ( $scope ) { $requestBody.scope = $scope}
    $response = Invoke-RestMethod -Uri $uri -Body $requestBody
    Write-Warning -Message $response.message -ErrorAction SilentlyContinue 
    return $response
}