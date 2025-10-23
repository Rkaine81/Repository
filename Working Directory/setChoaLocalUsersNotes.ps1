<#
Author: Adam Eaddy
Version: 1.0
Edited by: 
Date Created: 16/04/2024
Date Updated: 

Description:
    Rename Administrator to Guest and Disable
    Rename Guest to CHOAadmin and Enable
    Create new CHOA Admin Account (CUser)
    I will remove all notes after review for production
#>


# Obfuscate key values
# CUser (New Admin Account)
$UA1 = [string][char[]][int[]]("67.85.115.101.114".Split(".")) -replace " "

# Administrator
$UA2 = [string][char[]][int[]]("65.100.109.105.110.105.115.116.114.97.116.111.114".Split(".")) -replace " "

# Guest
$UA3 = [string][char[]][int[]]("71.117.101.115.116".Split(".")) -replace " "

# CHOAadmin (renamed Guest account)
$UA4 = [string][char[]][int[]]("67.72.79.65.97.100.109.105.110".Split(".")) -replace " "

# Administrators 
$UG1 = [string][char[]][int[]]("65.100.109.105.110.105.115.116.114.97.116.111.114.115".Split(".")) -replace " "

# Guest PW
$US1 = [string][char[]][int[]]("103.80.97.115.115.119.111.114.100.49.33".Split(".")) -replace " "

# New admin account PW
$US2 = [string][char[]][int[]]("99.80.97.115.115.119.111.114.100.49.33".Split(".")) -replace " "

# Guest Account Description
$DS1 = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('QgB1AGkAbAB0AC0AaQBuACAAYQBjAGMAbwB1AG4AdAAgAGYAbwByACAAZwB1AGUAcwB0ACAAYQBjAGMAZQBzAHMAIAB0AG8AIABjAG8AbQBwAHUAdABlAHIA'))

# Admin Account Description
$DS2 = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('QgB1AGkAbAB0AC0AaQBuACAAYQBjAGMAbwB1AG4AdAAgAGYAbwByACAAYQBkAG0AaQBuAGkAcwB0AGUAcgBpAG4AZwAgAHQAaABlACAAYwBvAG0AcAB1AHQAZQByAA=='))

# Store local Account details as PSObjects
$AA1 = glu -Name $UA2
$AG1 = glu -Name $UA3

# remove Local admin account from local admin group (Not Working)
# $mTR = "$env:COMPUTERNAME\$($AA1.Name)"
# rlgm -Group $UG1 -Member $mTR

# Rename the lcoal accounts
rnlu -InputObject $AG1 -NewName $UA4
rnlu -InputObject $AA1 -NewName $UA3

# Store local Account details as PSObjects with new names
$AA1 = glu -Name $UA3
$AG1 = glu -Name $UA4

# Randomize current local Admin PW
$nAP1 = [System.Guid]::NewGuid().ToString()
$nAP1s = ConvertTo-SecureString $nAP1 -AsPlainText -Force
slu -InputObject $AA1 -Password $nAP1s

# Enable local Guest account
elu -InputObject $AG1

# Set Guest password
$gP1 = ConvertTo-SecureString $US1 -AsPlainText -Force
slu -InputObject $AG1 -Password $gP1

# Disable local Admin account
dlu -InputObject $AA1

# Modify account descriptions
slu -InputObject $AA1 -Description $DS1
slu -InputObject $AG1 -Description "$DS2"

# Create new local admin account (CUser)
$cP1 = ConvertTo-SecureString $US2 -AsPlainText -Force
nlu -Name $UA1 -Password $cP1 -AccountNeverExpires

# Set account properteis
$nW = glu -Name $UA1
slu -InputObject $nW -AccountNeverExpires -PasswordNeverExpires $true

# Add new local user to local Admin group
algm -Group $UG1 -Member $UA1