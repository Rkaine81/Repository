<#
Rename Administrator to Guest and Disable
Rename Guest to Administrator and Enable
Create CHOA Admin Account (CUser)
#>

# Store local Account details as PSObjects
$Admin = Get-LocalUser -Name Administrator
$Guest = Get-LocalUser -Name Guest

# remove Local admin account from local admin group
# $memberToRemove = "$env:COMPUTERNAME\$($Admin.Name)"
# Remove-LocalGroupMember -Group Administrators -Member $memberToRemove

# Rename the lcoal accounts
Rename-LocalUser -InputObject $Guest -NewName CHOAadmin
Rename-LocalUser -InputObject $Admin -NewName Guest

# Store local Account details as PSObjects with new names
$Admin = Get-LocalUser -Name Guest
$Guest = Get-LocalUser -Name CHOAadmin

# Randomize current local Admin PW
$newAdminPassword1 = [System.Guid]::NewGuid().ToString()
$newAdminPassword1Secure = ConvertTo-SecureString $newAdminPassword1 -AsPlainText -Force
Set-LocalUser -InputObject $Admin -Password $newAdminPassword1Secure

# Enable local Guest account
Enable-LocalUser -InputObject $Guest

# Set Guest password
$gPassword = ConvertTo-SecureString 'gPassword1!' -AsPlainText -Force
Set-LocalUser -InputObject $Guest -Password $gPassword

# Disable local Admin account
Disable-LocalUser -InputObject $Admin

# Modify account descriptions
Set-LocalUser -InputObject $Admin -Description "Built-in account for guest access to computer"
Set-LocalUser -InputObject $Guest -Description "Built-in account for administering the computer"

# Create new local admin account (CUser)
$cPassword = ConvertTo-SecureString 'cPassword1!' -AsPlainText -Force
New-LocalUser -Name CUser -Password $cPassword -AccountNeverExpires

# Set account properteis
$newUser = Get-LocalUser -Name CUser
Set-LocalUser -InputObject $newUser -AccountNeverExpires -PasswordNeverExpires $true

# Add new local user to local Admin group
Add-LocalGroupMember -Group Administrators -Member CUser