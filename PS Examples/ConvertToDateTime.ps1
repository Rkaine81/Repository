Write-Host "This example is for the 24hr clock with HH"
Write-Host "ToUniversalTime() must be used when using [System.Management.ManagementDateTimeConverter]"
$my_date_24hr_time   = $policyUpdate
$date_format         = "yyyy-MM-dd HH:mm"
[System.Management.ManagementDateTimeConverter]::ToDateTime($my_date_24hr_time).ToUniversalTime();
[System.Management.ManagementDateTimeConverter]::ToDateTime($my_date_24hr_time).ToUniversalTime().ToSTring($date_format)
[datetime]::ParseExact($my_date_24hr_time,"yyyyMMddHHmmss.000000+000",$null).ToSTring($date_format)
Write-Host
Write-Host "-----------------------------"
Write-Host
Write-Host "This example is for the am pm clock with hh"
Write-Host "Again, ToUniversalTime() must be used when using [System.Management.ManagementDateTimeConverter]"
Write-Host
$my_date_ampm_time   = $policyUpdate
[System.Management.ManagementDateTimeConverter]::ToDateTime($my_date_ampm_time).ToUniversalTime();
[System.Management.ManagementDateTimeConverter]::ToDateTime($my_date_ampm_time).ToUniversalTime().ToSTring($date_format)
[datetime]::ParseExact($my_date_ampm_time,"yyyyMMddhhmmss.000000+000",$null).ToSTring($date_format)