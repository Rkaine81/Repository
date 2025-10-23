# Path: Get-ADUsersByJobTitle.ps1
# Import the Active Directory module
Import-Module ActiveDirectory
# Define the specific job title to search for
$specificJobTitle = "Radiologist"  # Replace with the job title you want to query
# Search the Active Directory for users with the specified job title
try {
   $users = Get-ADUser -Filter { Title -eq $specificJobTitle } -Property Name, Title, Department, EmailAddress
   if ($users.Count -eq 0) {
       Write-Output "No users found with job title '$specificJobTitle'."
   } else {
       Write-Output "Users with job title '$specificJobTitle':"
       $users | Select-Object Name, Title, Department, EmailAddress | Format-Table -AutoSize
   }
} catch {
   Write-Error "An error occurred: $_"
}


# Path: Get-ADUsersByDepartment.ps1
# Import the Active Directory module
Import-Module ActiveDirectory
# Define the keyword to search for in the department field (e.g., "Radiology")
$departmentKeyword = "Radiology"
# Construct the wildcard search pattern
$searchPattern = "*$departmentKeyword*"
# Search the Active Directory for users with departments containing the keyword
try {
   $users = Get-ADUser -Filter { Department -like $searchPattern } -Property Name, Department, EmailAddress, Title
   if ($users.Count -eq 0) {
       Write-Output "No users found with department containing '$departmentKeyword'."
   } else {
       Write-Output "Users in departments containing '$departmentKeyword':"
       $users | Select-Object Name, Department, Title, EmailAddress | Format-Table -AutoSize
   }
} catch {
   Write-Error "An error occurred: $_"
}