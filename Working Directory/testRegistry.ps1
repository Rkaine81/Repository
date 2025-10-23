#Function to test registry value existance.
#Example: Test-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 
function Test-RegistryValue {

    param (

     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,

    [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value
    )

    try {

        Get-ItemProperty -Path $Path -Name $Value -ErrorAction Stop | Out-Null
        return $true
    }

    catch {

    return $false

    }

}

Test-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 

