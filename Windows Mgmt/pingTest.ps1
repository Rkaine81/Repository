$results = Test-NetConnection -ComputerName choa.org

if ($results.PingReplyDetails.RoundtripTime -lt 40) {
    return $true
}else{
    return $false
}