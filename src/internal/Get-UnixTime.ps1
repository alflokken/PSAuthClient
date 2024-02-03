function Get-UnixTime {
    <#
    .SYNOPSIS
    Get the current time in Unix time.
    .DESCRIPTION
    Get the time in Unix time (seconds since the Epoch)
    .PARAMETER date
    The date to convert to Unix time. If not specified, the current date and time is used.
    .EXAMPLE
    Get-UnixTime
    1706961267
    #>
    param( [Parameter(Mandatory=$false,ValueFromPipeline=$true)] [DateTime]$date = (Get-Date) )
    return [int64](New-TimeSpan -Start (Get-Date "1970-01-01T00:00:00Z").ToUniversalTime() -End ($date).ToUniversalTime()).TotalSeconds    
}