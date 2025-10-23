$templateName = 'CHOA Computer'
$cert = Get-ChildItem 'Cert:\LocalMachine\My' | Where-Object{ $_.Extensions | Where-Object{ ($_.Oid.FriendlyName -eq 'Certificate Template Information') -and ($_.Format(0) -match $templateName) }}

#$cert.NotAfter
$today = get-date

If ($cert.count -gt 1) {
    write-output "More than 1 cert"
    $expiredCount = 0
    foreach ($certObj in $cert) {
        if (($certObj.NotAfter) -lt $today) {
            $expiredCount = $expiredCount + 1
        }
    }
    if ($expiredCount -eq 0) {
        return $true
    }else{
        return $false
    }
}else{
    if (($cert.NotAfter) -lt $today) {
        return $false
    }else{
        return $true
    }
}