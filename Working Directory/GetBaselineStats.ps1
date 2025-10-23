#$CMPSSuppressFastNotUsedCheck = $true
$baseLine = Get-CMBaseline -Id 16859348
Get-CMBaselineDeploymentStatus -InputObject $baseLine
Get-CMBaselineDeployment -InputObject $baseLine
