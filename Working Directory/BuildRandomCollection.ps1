Param(
    [Parameter(Mandatory=$true)]
    [string]$NewCollectionName,
    #[Parameter(Mandatory=$true)]
    #[string]$CSVPath,
    [string]$newCSVPath = "C:\choa"
)



<# Logging Function
Example: Write-Log "This is a log entry."
#>
Function Write-Log {

    param(
        [Parameter(Mandatory=$true)]
        [string]$VALUE
    )

    $SDATE = get-date -Format MMddyyyy
    $LOGPATH = "C:\CHOA"
    #Set Log name
    $LOGFILE = "RandomCollections_$SDATE.log"
    $FULLLOGPATH = "$LOGPATH\$LOGFILE"

    write-output "$(get-date): $VALUE" | out-file $FULLLOGPATH -Append -Force -NoClobber

}

$NewCollectionName = "Random Collection - Citrix - 08-05-24"
$CSVPath = "C:\Users\179944\OneDrive - CHOA\scripts\working directory\sitelist.csv"

Write-Log "Importing CSV file: $CSVPath."
Write-output "Importing CSV file: $CSVPath."

$CSV = Import-Csv -Path $CSVPath -Header collections

Write-Log "Connectin to SCCM Site"
Write-output "Connectin to SCCM Site"

$SiteCode = "P01" 
$ProviderMachineName = "DCVWP-SCCMAP01.choa.org" 
$initParams = @{}
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams | Out-Null
}

Write-Log "Creating new Device Collection: $NewCollectionName."
Write-output "Creating new Device Collection: $NewCollectionName."

Set-Location "$($SiteCode):\" @initParams

$pilotColl = New-CMDeviceCollection -Name $NewCollectionName -LimitingCollectionId P010028E -RefreshType None -Comment "Create with BuildRandomCollection PowerShell script on $(get-date) by $($env:USERNAME)."

$count = 1

foreach ($obj in $CSV) {
 
    $site = $obj.collections

    $coll = Get-CMDeviceCollection -Name $site
    Write-Output "$($coll.Name)"
    Write-Log "$($coll.Name)"

    $devices = Get-CMCollectionMember -InputObject $coll

    Write-Output "Getting random object for $site"
    Write-Log "Getting random object for $site"

    if (!($null -eq $devices)) {
        $winner = Get-Random -InputObject $devices -Count $count
        Write-Output "$($winner.Name)"
        Write-Log "$($winner.Name)"
        $wID = $winner.ResourceID

        Write-Host "Adding device to collection." -ForegroundColor Green
        Write-Log "Adding device to collection."
        Add-CMDeviceCollectionDirectMembershipRule -InputObject $pilotColl -ResourceId $wID
        Write-Output "$($winner.Name),$($coll.Name)" | Out-File "$newCSVPath\$NewCollectionName.csv"  -Force -Append
    }else{
        Write-Host "$site is empty" -ForegroundColor Yellow
        Write-Log "$site is empty"
    }
}


Write-Output "Adding exclusions."
Write-Log "Adding exclusions."
$exclusions = Get-CMDeviceCollection -Id P01015A6
Add-CMDeviceCollectionExcludeMembershipRule -InputObject $pilotColl -ExcludeCollection $exclusions

Write-Output "Closing connection and completing."
Write-Log "Closing connection and completing."

Set-Location -Path 'C:'

Remove-PSDrive -Name 'P01' -Force -ErrorAction 'SilentlyContinue' > $null
