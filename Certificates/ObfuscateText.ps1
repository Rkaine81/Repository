Param([Parameter(Mandatory=$true)][string]$password)
$var0=[int[]][char[]]$password
$var1=[int[]][char[]]$var0 -join "."
cls
Write-Host The output below can be used in a script in place of a password:
write-host [string][char[]][int[]]'("'$var1'".Split(".")) -replace " "'


<#Example
[string][char[]][int[]]("116.104.105.115.105.115.110.111.116.109.121.114.101.97.108.112.97.115.115.119.111.114.100".Split(".")) -replace " "
!#>