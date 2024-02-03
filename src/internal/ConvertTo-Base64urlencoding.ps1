function ConvertTo-Base64UrlEncoding {
    <# 
    .SYNOPSIS
    Convert a a string to base64url encoding.
    .DESCRIPTION
    Base64-URL-encoding is a minor variation on the typical Base64 encoding method, but uses URL-safe characters instead. 
    .PARAMETER value
    string to convert
    .EXAMPLE
    ConvertTo-Base64UrlEncoding -value "{"typ":"JWT","alg":"RS25....}
    eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2hIYm5BdyJ9
    #>
    param ([Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]$value)
    if ( $value.GetType().Name -eq "String" ) { $value = [System.Text.Encoding]::UTF8.GetBytes($value) }
    # change + to -, and / to _, then trim the trailing = from the end.
    return ( [System.Convert]::ToBase64String($value) -replace '\+','-' -replace '/','_' -replace '=' )
}