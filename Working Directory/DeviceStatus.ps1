
param(
        [Parameter(Mandatory)]
        [string]$Devices
     )

$ErrorActionPreference = "SilentlyContinue"

Write-Output "You entered $($Devices)."

if ($Devices -like "*.csv") {
    $list = Import-Csv -Path devices -Header Computer
    Write-Output "CSV"
}

if ($Devices -like "*.txt") {
    $list = get-content -Path $Devices
    Write-Output "TXT"
}

if (!($Devices -like "*.txt") -or ($Devices -like "*.csv")) {
    $list = $Devices
    Write-Output "LIST"
}

write-out "The list contains $($list)."

# Begin SCCM Connection
Write-Host "Begin SCCM Configuration."
Write-Host "Checking for SCCM Console."
If (!(test-path -Path $ENV:SMS_ADMIN_UI_PATH)) {
    Write-Host "Could not find SCCM Console.  Please install the SCCM console and try again."
    Exit 1
}
Write-Host "SCCM Console foiund at $ENV:SMS_ADMIN_UI_PATH."
Write-Host "Connecting to SCCM PowerShell environment."
Try {
$ErrorActionPreference = 'Stop'
    # SCCM Site configuration and connection
    $SiteCode = "P01" # Site code 
    $ProviderMachineName = "dcvwp-sccmap01.choa.org" # SMS Provider machine name
    $initParams = @{}
        # Import the ConfigurationManager.psd1 module 
    if($null -eq (Get-Module ConfigurationManager)) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }
        # Connect to the site's drive if it is not already present
    if($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }
        # Set the current location to be the site code.
        Set-Location "$($SiteCode):\" @initParams
        Write-Host "Successfully connected to the SCCM site." -ForegroundColor Green
}
Catch {
    Write-Host "Failed to connect to the SCCM site." -ForegroundColor Red
    #write-log "Failed to connect to the SCCM site."
    #write-log "Error Details: $ErrorMessage; Description: $_;"
}

foreach ($DeviceName in $list) {
    Write-Output $DeviceName

    $currentDate = (get-date)

    $connectionDetails = New-Object -TypeName PSCustomObject
    $connectionDetails = New-Object -TypeName PSCustomObject -Property @{
        DeviceName = $DeviceName
    }

    $ipTest = $null
    $ipTest = Test-NetConnection $DeviceName
    if (($iptest.PingSucceeded) -eq "True") {$connectionDetails | Add-Member -MemberType NoteProperty -Name "PingSucceeded" -Value "True"}else{$connectionDetails | Add-Member -MemberType NoteProperty -Name "PingSucceeded" -Value "False"}

    $connectionDetails | Add-Member -MemberType NoteProperty -Name "TodaysDate" -Value $currentDate

    $cmTest = $null
    $cmTest = Get-CMDevice -Name $DeviceName #| FT ADLastLogonTime, LastClientCheckTime, LastActiveTime
    if ($null -eq $cmTest) {
        $connectionDetails | Add-Member -MemberType NoteProperty -Name "CM.Present" -Value "False"
    }else{
        $connectionDetails | Add-Member -MemberType NoteProperty -Name "CM.Present" -Value "True"
        $connectionDetails | Add-Member -MemberType NoteProperty -Name "CM.ADLastLogonTime" -Value ($cmTest.ADLastLogonTime)
        $connectionDetails | Add-Member -MemberType NoteProperty -Name "CM.LastClientCheckTime" -Value ($cmTest.LastClientCheckTime)
        $connectionDetails | Add-Member -MemberType NoteProperty -Name "CM.LastActiveTime" -Value ($cmTest.LastActiveTime)
    }

    try {
        $adTest = $null
        $adTest = Get-ADComputer -Identity $DeviceName -Properties * -ErrorAction SilentlyContinue
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        $FullMessage = $Error[0].Exception.GetType().FullName
    }
    if ($null -eq $adTest) {
            $connectionDetails | Add-Member -MemberType NoteProperty -Name "AD.Present" -Value "False"
    }else{
        $connectionDetails | Add-Member -MemberType NoteProperty -Name "AD.Present" -Value "True"
        $connectionDetails | Add-Member -MemberType NoteProperty -Name "AD.Lastlogondate" -Value ($adTest.Lastlogondate)
    }

    #Set-Variable -Name $DeviceName -Value $connectionDetails

    $connectionDetails

    Write-Output "$($connectionDetails.DeviceName),$($connectionDetails.PingSucceeded ),$($connectionDetails.TodaysDate),$($connectionDetails.CM.Present),$($connectionDetails.CM.ADLastLogonTime),$($connectionDetails.CM.LastClientCheckTime),$($connectionDetails.CM.LastActiveTime),$($connectionDetails.AD.Present),$($connectionDetails.AD.Lastlogondate)"

    #clear PSObject
    $connectionDetails.psobject.properties.remove("DeviceName")
    $connectionDetails.psobject.properties.remove("PingSucceeded")
    $connectionDetails.psobject.properties.remove("TodaysDate")
    $connectionDetails.psobject.properties.remove("CM.Present")
    if (!($null -eq ($connectionDetails.'CM.ADLastLogonTime'))) {$connectionDetails.psobject.properties.remove("CM.ADLastLogonTime")}
    if (!($null -eq ($connectionDetails.'CM.LastClientCheckTime'))) {$connectionDetails.psobject.properties.remove("CM.LastClientCheckTime")}
    if (!($null -eq ($connectionDetails.'CM.LastActiveTime'))) {$connectionDetails.psobject.properties.remove("CM.LastActiveTime")}
    $connectionDetails.psobject.properties.remove("AD.Present")
    if (!($null -eq ($connectionDetails.'AD.Lastlogondate'))) {$connectionDetails.psobject.properties.remove("AD.Lastlogondate")}
}