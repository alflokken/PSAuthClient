function New-HttpListener {     
    <#
    .SYNOPSIS
    Create new HttpListener object and listen for incoming requests.
    .DESCRIPTION
    Create new HttpListener object and listen for incoming requests.
    .PARAMETER prefix
    The URI prefix handled by the HttpListener object, typically a redirect_uri.
    .EXAMPLE
    New-HttpListener -prefix "http://localhost:8080/"
    Waits for a request on http://localhost:8080/ and returns the post data.
    .EXAMPLE
    $job = Start-Job -ScriptBlock (Get-Command 'New-HttpListener').ScriptBlock -ArgumentList $redirect_uri
    Starts a Job which waits for a request on $redirect_uri.
    #>
    param(
        [parameter(Position = 0, Mandatory = $true, HelpMessage="The URI prefix handled by the HttpListener object, typically the redirect_uri.")]
        [string]$prefix
    )
    try {
        # start http listener
        $httpListener = New-Object System.Net.HttpListener
        $httpListener.Prefixes.Add($prefix)
        $httpListener.Start()
        # wait for request
        $context = $httpListener.GetContext()
        # read post request
        $form_post = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()
        # send a response
        $context.Response.StatusCode = 200
        $context.Response.ContentType = 'application/json'
        $responseBytes = [System.Text.Encoding]::UTF8.GetBytes('')
        $context.Response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
        # clean up
        $context.Response.Close()
        $httpListener.Close()
    }
    catch { throw $_ } 
    return $form_post
}