

#Define Variables
$DATE = Get-Date
$SDATE = get-date -Format MMddyyyy
$LOGPATH = "C:\Users\179944\OneDrive - CHOA\scripts\working directory"
$LOGFILE = "DeviceCount.log"
$FULLLOGPATH = "$LOGPATH\$LOGFILE"


Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )


    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

$CSVFILE = "C:\Users\179944\OneDrive - CHOA\scripts\working directory\sitelist.csv"
$DATALIST = Import-Csv -Path $CSVFILE -Header name


# Begin SCCM Connection
Write-Host "Begin SCCM Configuration."
Write-Host "Checking for SCCM Console."
Write-Log "Checking for SCCM console."
If (!(test-path -Path $ENV:SMS_ADMIN_UI_PATH)) {
    Write-Host "Could not find SCCM Console.  Please install the SCCM console and try again."
    write-log "Could not find SCCM Console.  Please install the SCCM console and try again." 
    Exit 1
}
Write-Host "SCCM Console foiund at $ENV:SMS_ADMIN_UI_PATH."
write-log "SCCM Console found at $ENV:SMS_ADMIN_UI_PATH."
Write-Host "Connecting to SCCM PowerShell environment."
write-log "Connecting to SCCM PowerShell environment."
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
        write-log "Successfully connected to the SCCM site."
        write-log "SCCM Settings:"
        write-log "Site Code: $SiteCode"
        write-log "SCCM Server: $ProviderMachineName "
        write-log "SCCM Console Path: $ENV:SMS_ADMIN_UI_PATH"
}
Catch {
    Write-Host "Failed to connect to the SCCM site." -ForegroundColor Red
    write-log "Failed to connect to the SCCM site."
    write-log "Error Details: $ErrorMessage; Description: $_;"
}

$c = 0
foreach ($loc in $DATALIST) {
    $coll = Get-CMDeviceCollection -Name ($loc.name)
    Write-Output "$C"
    write-output $coll.membercount
    $c = $c+($coll.MemberCount)
    Write-Output "New total is $C."
}