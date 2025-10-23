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
                $cert
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

Check-ManagementPointCommunication -certType User