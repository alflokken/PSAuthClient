function Get-RandomString { 
    <#
    .SYNOPSIS
    Generate a random string.
    .DESCRIPTION
    Generate a random string of a given length, by default between 43 and 128 characters.
    .PARAMETER Length
    The length of the string to generate.
    .EXAMPLE
    Get-RandomString
    95TFIttXFdwvhW8DCXVhlHqsld62U_NlxlQe.YqdN.Hm5xs8S3.bTISQ
    #>
    param( [int]$Length = ((43..128) | get-random) )
    $charArray = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~".ToCharArray()
    if ( $PSVersionTable.PSVersion -ge "7.4.0" ) { $randomizedCharArray = for ( $i = 0; $i -lt $Length; $i++ ) { $charArray[(0..($charArray.count-1) | Get-SecureRandom)] } }
    else { $randomizedCharArray = for ( $i = 0; $i -lt $Length; $i++ ) { $charArray[(0..($charArray.count-1) | Get-Random)] } }
    return [string](-join $randomizedCharArray)
}