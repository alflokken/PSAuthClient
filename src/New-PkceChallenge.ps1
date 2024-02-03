function New-PkceChallenge { 
    <#
    .SYNOPSIS
    Generate code_verifier and code_challenge for PKCE (authorization code flow).
    .DESCRIPTION
    Generate code_verifier and code_challenge for PKCE (authorization code flow).
    .EXAMPLE
    PS> New-PkceChallenge
    code_verifier                  Vpq2YXOsD~1DRM-jBPR6bt8R-3dWQAHNLVLUIDxh7SkWpOT3A0grpenqKne5rAHcVKsTi-ya8-lGBxJ0NS7zavdcFbfdN0yFQ5kYOFbWBh3
    code_challenge                 TW-3r-6mxRWjhkkxmYOabLlwIQ0JkQ0ndxzOSLJvCoU
    code_challenge_method          S256
    #>
    # Generate code_verifier and code_challenge for PKCE (authorization code flow).
    $response = [ordered]@{}
    # code_verifier (should be a random string using the characters "[A-Z,a-z,0-9],-._~" between 43 and 128 characters long)
    [string]$response.code_verifier = Get-RandomString
    # dereive code_challenge from code_verifier (SHA256 hash) and encode using base64urlencoding (fallback to plain)
    try { 
        $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create('sha256') 
        $hashInBytes = $hashAlgorithm.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($response.code_verifier))
        [string]$response.code_challenge = ConvertTo-Base64urlencoding $hashInBytes
        [string]$response.code_challenge_method = "S256"
    }
    catch {
        [string]$response.code_challenge = $response.code_verifier
        [string]$response.code_challenge_method = "plain"
    }  
    return $response
}