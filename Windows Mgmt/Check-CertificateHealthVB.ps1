param (
    [Parameter(Mandatory=$false)]
    [switch]$report
)



# Function to check communication with the Management Point
function Check-ManagementPointCommunication() {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Computer", "User")]
        [string]$certType
    )

    try {
        If ($certType -eq "Computer") {
            $cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {
                $_.Extensions | Where-Object {
                    $_.Oid.FriendlyName -eq "Certificate Template Information" -and
                    $_.Format(0) -match "CHOA Computer"
                }
            }
        }else{
            $cert = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object {
                $_.Extensions | Where-Object {
                    $_.Oid.FriendlyName -eq "Certificate Template Information" -and
                    $_.Format(0) -match "User-TEAP"
                }
            }
        }

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        $mpListLocation = ((Get-WmiObject -Namespace "root\ccm" -Class "SMS_LookupMP" -ErrorAction SilentlyContinue).Name).split(".")[0]
        #$mpListLocation = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\CCM\LocationServices" -Name "ManagementPoint" -ErrorAction SilentlyContinue).ManagementPoint
        if ($mpListLocation) {
            $mpUrl = "https://$mpListLocation/SMS_MP/.sms_aut?mplist"
            $response = Invoke-WebRequest -Uri $mpUrl -Certificate $cert
            if ($response.StatusCode -eq 200) {
                return "Success"
            } else {
                return "Failed"
            }
        } else {
            return "Failed"
        }
    } catch {
        return "Failed"
    }
}

function Get-CertInfo {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Computer", "User")]
        [string]$certType,

        [Parameter(Mandatory=$true)]
        [ValidateSet("My", "CA", "Root", "Trust", "Request")]
        [string]$certStore
    )

    # Define the number of days to check for upcoming expiration
    $expirationThreshold = 30

    If ($certType -eq "Computer") {
        $certificates = Get-ChildItem -Path Cert:\LocalMachine\$certStore
    }else{
        $certificates =  Get-ChildItem -Path Cert:\CurrentUser\$certStore
    }

    # Initialize an array to store certificate details
    $certDetailsArray = @()

    # Check each certificate
    foreach ($cert in $certificates) {
        $expirationDate = $cert.NotAfter
        $daysUntilExpiration = ($expirationDate - (Get-Date)).Days

        # Determine the healthy status and expiration status
        if ($expirationDate -lt (Get-Date)) {
            $healthyStatus = "Expired"
            $expirationStatus = "Expired"
        } elseif ($daysUntilExpiration -le $expirationThreshold) {
            $healthyStatus = "Warning"
            $expirationStatus = "Will expire in $daysUntilExpiration days"
        } else {
            $healthyStatus = "Healthy"
            $expirationStatus = "Valid"
        }

        # Retrieve and join the friendly names of the enhanced key usages
        $certTemplate = ($cert.EnhancedKeyUsageList | ForEach-Object { $_.FriendlyName }) -join ", "

        # Create a PSObject with the desired properties
        $certDetails = [PSCustomObject]@{
            CertSubject     = $cert.Subject
            CertTemplate    = $certTemplate
            HealthyStatus   = $healthyStatus
            ExpirationStatus = $expirationStatus
            ExpirationDate = $expirationDate
        }

        # Add the PSObject to the array
        $certDetailsArray += $certDetails
    }

    # Output the array of certificate details
    $certDetailsArray
}

function Get-CertUtilResults {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("My", "CA", "Root", "Trust", "Request")]
        [string]$certStore,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Computer", "User")]
        [string]$certType
    )

    # Initialize an array to store the certificate objects
    $certificates = @()

    if ($certType -eq "Computer"){
        $inputData = certutil -store $certStore
    }else{
        $inputData = certutil -user -store $certStore
    }

    # Initialize variables to track certificate data
    $currentCert = $null
    $certName = ""

    # Iterate over each line in the input data
    foreach ($line in $inputData) {
        if ($line -match '================ Certificate (\d+) ================') {
            # If a certificate header is found, finalize the previous certificate object (if any)
            if ($currentCert) {
                $certificates += $currentCert
            }

            # Create a new PSObject for the current certificate
            $certName = "Certificate$($matches[1])"
            $currentCert = New-Object PSObject -Property @{
                Name = $certName
                Details = @()
            }
        } elseif ($currentCert -and $line -notmatch '^\s*$') {
            # Add the line to the current certificate's details if it's not empty
            $currentCert.Details += $line.Trim()
        }
    }

    # Add the last certificate object to the array
    if ($currentCert) {
        $certificates += $currentCert
    }


    $results = @()
    Foreach ($certObj in $certificates) {
        $results += $certObj.Name
        $results += $certObj.Details
        $results += "`n"

    }

    return $results
}

If ($report) {

    $CompCertInfo = Get-CertInfo -certType Computer -certStore My
    $UserCertInfo = Get-CertInfo -certType User -certStore My
    

    Function Get-CertUnHealthyCount {
        param (
            $certImport
        )

        $n = 0
        Foreach ($obj in $certImport) {
            If ($obj.HealthyStatus -ne "Healthy") {
                $n = $n + 1
            }
        }
        return $n
    }

    $compErrorCount = Get-CertUnHealthyCount -certImport $CompCertInfo
    $UserErrorCount = Get-CertUnHealthyCount -certImport $UserCertInfo

    # Gather all results into a single PSObject
    $CertCheckResults = [PSCustomObject]@{
        ComputerCertCheck = Check-ManagementPointCommunication -certType Computer
        UserCertCheck = Check-ManagementPointCommunication -certType User 
        CompCertHealth = if (($compErrorCount -eq 0) -and ($(Check-ManagementPointCommunication -certType Computer) -eq "Success")) {"Healthy."}else{"Please review Certificates"}
        UserCertHealth = if (($userErrorCount -eq 0) -and ($(Check-ManagementPointCommunication -certType User) -eq "Success")) {"Healthy."}else{"Please review Certificates"}
        CompClientAuthHealth = if ((($CompCertInfo.certTemplate) -eq "Client Authentication") -and (($compCertInfo.HealthyStatus) -eq "Healthy")) {"Healthy"}else{"Unhealthy"}
        UserClientAuthHealth = if ((($UserCertInfo.certTemplate) -eq "Encrypting File System, Secure Email, Client Authentication") -and (($compCertInfo.HealthyStatus) -eq "Healthy")) {"Healthy"}else{"Unhealthy"}
        ExpiredComputerCertificateCount = "$($compErrorCount) of $($compCertInfo.Count)"
        ExpiredUserCertificateCount = "$($userErrorCount) of $($userCertInfo.Count)"
    }

    $results = @()
    $results += "Full Computer Certificate List:`n"
    $results += Get-CertUtilResults -certType Computer -certStore My
    $results += Get-CertInfo -certType Computer -certStore My
    $results += "Full User Certificate List:`n"
    $results += Get-CertUtilResults -certType User -certStore My
    $results += Get-CertInfo -certType User -certStore My
    $results += "`n"
    $results += "Computer Certificate Test:    $($CertCheckResults.ComputerCertCheck)"
    $results += "User Certificate Test:        $($CertCheckResults.UserCertCheck)"
    $results += "Expired Computer Certificates:     $($CertCheckResults.ExpiredComputerCertificateCount)"
    $results += "Expired User Certificates:         $($CertCheckResults.ExpiredUserCertificateCount)"
    $results += "Client Auth Computer Cert Health:     $($CertCheckResults.CompClientAuthHealth)"
    $results += "User Auth Computer Cert Health:       $($CertCheckResults.UserClientAuthHealth)"
    $results += "Overall Computer Certificate Health:     $($CertCheckResults.CompCertHealth)"
    $results += "Overall User Certificate Health:         $($CertCheckResults.UserCertHealth)"


    return $results


}else{


    $CompCertInfo = Get-CertInfo -certType Computer -certStore My
    $UserCertInfo = Get-CertInfo -certType User -certStore My
    

    Function Get-CertUnHealthyCount {
        param (
            $certImport
        )

        $n = 0
        Foreach ($obj in $certImport) {
            If ($obj.HealthyStatus -ne "Healthy") {
                $n = $n + 1
            }
        }
        return $n
    }

    $compErrorCount = Get-CertUnHealthyCount -certImport $CompCertInfo
    $UserErrorCount = Get-CertUnHealthyCount -certImport $UserCertInfo
    
    

    # Gather all results into a single PSObject
    $CertCheckResults = [PSCustomObject]@{
        ComputerCertCheck = Check-ManagementPointCommunication -certType Computer
        UserCertCheck = Check-ManagementPointCommunication -certType User 
        CompCertHealth = if (($compErrorCount -eq 0) -and ($(Check-ManagementPointCommunication -certType Computer) -eq "Success")) {"Healthy."}else{"Please review Certificates"}
        UserCertHealth = if (($userErrorCount -eq 0) -and ($(Check-ManagementPointCommunication -certType User) -eq "Success")) {"Healthy."}else{"Please review Certificates"}
        CompClientAuthHealth = if ((($CompCertInfo.certTemplate) -eq "Client Authentication") -and (($compCertInfo.HealthyStatus) -eq "Healthy")) {"Healthy"}else{"Unhealthy"}
        UserClientAuthHealth = if ((($UserCertInfo.certTemplate) -eq "Encrypting File System, Secure Email, Client Authentication") -and (($compCertInfo.HealthyStatus) -eq "Healthy")) {"Healthy"}else{"Unhealthy"}
        ExpiredComputerCertificateCount = "$($compErrorCount) of $($compCertInfo.Count)"
        ExpiredUserCertificateCount = "$($userErrorCount) of $($userCertInfo.Count)"
    }

    $results = @()
    $results += "Computer Certificate Test:    $($CertCheckResults.ComputerCertCheck)"
    $results += "User Certificate Test:        $($CertCheckResults.UserCertCheck)"
    $results += "Expired Computer Certificates:     $($CertCheckResults.ExpiredComputerCertificateCount)"
    $results += "Expired User Certificates:         $($CertCheckResults.ExpiredUserCertificateCount)"
    $results += "Client Auth Computer Cert Health:     $($CertCheckResults.CompClientAuthHealth)"
    $results += "User Auth Computer Cert Health:       $($CertCheckResults.UserClientAuthHealth)"
    $results += "Overall Computer Certificate Health:     $($CertCheckResults.CompCertHealth)"
    $results += "Overall User Certificate Health:         $($CertCheckResults.UserCertHealth)"




    return $results


}
