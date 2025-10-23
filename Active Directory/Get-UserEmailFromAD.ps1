# File: Get-UserEmailFromAD.ps1
# Import required module for Active Directory
Import-Module ActiveDirectory
# Input and Output file paths
$InputFile = "C:\Temp\AD User Email Addr\Users.txt"  # Replace with your input text file
$OutputFile = "C:\Temp\AD User Email Addr\UserEmails.csv" # Replace with your desired output CSV file
# Initialize an array to store results
$Results = @()
# Read usernames from the input file
if (Test-Path $InputFile) {
   $Usernames = Get-Content -Path $InputFile
} else {
   Write-Error "Input file not found: $InputFile"
   exit 1
}
# Loop through each username to query AD
foreach ($Username in $Usernames) {
   # Trim any extra whitespace
   $Username = $Username.Trim()
   if ($Username -ne "") {
       try {
           # Get the user's email address from AD
           $User = Get-ADUser -Identity $Username -Properties EmailAddress
           if ($User) {
               # Add the result to the array
               $Results += [PSCustomObject]@{
                   Username   = $Username
                   Email      = $User.EmailAddress
               }
           } else {
               Write-Warning "User not found in AD: $Username"
           }
       } catch {
           Write-Warning "Error retrieving user from AD: $Username - $_"
       }
   }
}
# Export results to CSV
if ($Results.Count -gt 0) {
   $Results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
   Write-Host "Results saved to $OutputFile"
} else {
   Write-Warning "No results to save."
}