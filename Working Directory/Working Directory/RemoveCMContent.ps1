$appCSVPath1 = "C:\Users\179944\OneDrive - CHOA\Documents\CM Cleanup\CM_Applications_edited.csv"

$pkgCSVPath1 = "C:\Users\179944\OneDrive - CHOA\Documents\CM Cleanup\CM_Packages_edited.csv"

$appCSV1 = import-csv -Path $appCSVPath1

$pkgCSV1 = import-csv -Path $pkgCSVPath1


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

foreach ($pkgCSV1Obj in $pkgcsv1) {

    if ($pkgCSV1Obj.CanDelete -eq "YES" -and $pkgCSV1Obj.Name -ne "Configuration Manager Client Package" ) {
        Write-Output "Removing $($pkgCSV1Obj.Name)"
        Get-CMPackage -Name ($pkgCSV1Obj.Name) -Fast | Remove-CMPackage -Force

    }
}



foreach ($appCSV1Obj in $appcsv1) {

    if ($appCSV1Obj.CanDelete -eq "YES") {
        Write-Output "Removing $($appCSV1Obj.LocalizedDisplayName)"
        Get-CMApplication -Fast -Name ($appCSV1Obj.LocalizedDisplayName) | Remove-CMApplication -Force

    }
}

