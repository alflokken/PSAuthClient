function Convert-UnixTime {
    <#
    .SYNOPSIS
    Convert UnixTime to DateTime and vice versa. 
    .DESCRIPTION
    Convert UnixTime to DateTime and vice versa. 
    .PARAMETER date
    The date to convert to Unix time. If not specified, the current date and time is used.
    .PARAMETER epoch
    Unix epoch to convert to DateTime.
    .EXAMPLE
    Get-UnixTime
    1706961267
    .EXAMPLE
    Get-UnixTime -epoch 1728896669
    Monday, 14 October 2024 11:04:29
    #>
    [Alias('Get-UnixTime')]
    [OutputType([int64],[DateTime])]
    [cmdletbinding(DefaultParameterSetName='fromDateTime')]
    param( 
        [Parameter(Position = 0, ParameterSetName='fromDateTime',Mandatory=$false,ValueFromPipeline=$true)] [DateTime]$date = (Get-Date),
        [Parameter(Position = 0, ParameterSetName='fromEpoch',Mandatory=$false,ValueFromPipeline=$true)] [int64]$epoch
    )
    switch ( $PSCmdlet.ParameterSetName ) {
        "fromDateTime" { return [int64](New-TimeSpan -Start (Get-Date "1970-01-01T00:00:00Z").ToUniversalTime() -End ($date).ToUniversalTime()).TotalSeconds }
        "fromEpoch" { return (New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0).AddSeconds($epoch).ToLocalTime() }
    }
}