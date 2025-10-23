#Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsImxpbmtlZFVzZXJzIjpbIjYzMTdlMGYxZDIyOGE3NGQ0MzIwMjg2NCJdLCJzY29wZXMiOltdLCJpYXQiOjE2NjMxODE4ODYsImp0aSI6IjM4NDNiZGY0LWIyNGUtNDNiYi1iZTI1LTdhMTBlMzBhOTBiZCJ9.JQjT2PTESrTHtKpILyobNAlh2a4G8KytnJTfK-BoNAg

#function to Save Credentials to a file
Function Save-Credential([string]$UserName, [string]$KeyPath)
{
    #Create directory for Key file
    If (!(Test-Path $KeyPath)) {       
        Try {
            New-Item -ItemType Directory -Path $KeyPath -ErrorAction STOP | Out-Null
        }
        Catch {
            Throw $_.Exception.Message
        }
    }
    #store password encrypted in file
    $Credential = Get-Credential -Message "Enter the Credentials:" -UserName $UserName
    $Credential.Password | ConvertFrom-SecureString | Out-File "$($KeyPath)\$($Credential.Username).cred" -Force
}
 
#Get credentials and create an encrypted password file
Save-Credential -UserName "remediant" -KeyPath "C:\PSScripts\KeyFiles"





#function to get credentials from a Saved file
Function Get-SavedCredential([string]$UserName,[string]$KeyPath)
{
    If(Test-Path "$($KeyPath)\$($Username).cred") {
        $SecureString = Get-Content "$($KeyPath)\$($Username).cred" | ConvertTo-SecureString
        $Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString
    }
    Else {
        Throw "Unable to locate a credential for $($Username)"
    }
    Return $Credential
}
 
#Get encrypted password from the file
$Cred = Get-SavedCredential -UserName "remediant" -KeyPath "C:\PSScripts\KeyFiles"
 
#Connect to Azure AD from saved credentials
Write-Output $Cred.Password


