# Get all devices from WMI
$devices = Get-WmiObject Win32_PnPEntity

# Filter devices that have issues, such as missing drivers
$devicesWithIssues = $devices | Where-Object {
    $_.ConfigManagerErrorCode -ne 0
}

# Display information about devices with missing drivers
if ($devicesWithIssues.Count -eq 0) {
    return "No devices with missing drivers found."
} else {
    $results = @()
    $results += "Devices with missing drivers:`n"

    foreach ($device in $devicesWithIssues) {

        # Gather all results into a single PSObject
        $healthCheckResults = [PSCustomObject]@{
            deviceName = $device.Name
            deviceStatus = $device.Status
            errorCode = $device.ConfigManagerErrorCode
            deviceID = $device.DeviceID
        }

        $results += "----------------------------------------"
        $results += "Device Name: " + $healthCheckResults.deviceName
        $results += "Device ID  : " + $healthCheckResults.deviceID
        $results += "Status     : " + $healthCheckResults.deviceStatus
        $results += "Error Code : " + $healthCheckResults.errorCode
        $results += "----------------------------------------"

    }

    return $results


}