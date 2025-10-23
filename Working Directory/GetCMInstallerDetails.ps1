$appCSVPath = "C:\Users\179944\OneDrive - CHOA\Documents\CM Cleanup\CM_Applications.csv"

$pkgCSVPath = "C:\Users\179944\OneDrive - CHOA\Documents\CM Cleanup\CM_Packages.csv"

$appCSV = import-csv -Path $appCSVPath

$pkgCSV = import-csv -Path $pkgCSVPath

$pkgBkup = "C:\Users\179944\OneDrive - CHOA\Documents\CM Cleanup\CMPkg_Bkup.csv"

$appBkup = "C:\Users\179944\OneDrive - CHOA\Documents\CM Cleanup\CMApp_Bkup.csv"

Write-Output "PackageName, ProgramName, InstallString" | out-file $pkgBkup -Append -Force

Write-Output "ApplicationName, DeploymentTypeName, InstallString" | out-file $appBkup -Append -Force


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

$CMPSSuppressFastNotUsedCheck = $true
<#
foreach ($pkg in $pkgCSV) {
    $cmPkgObj = Get-CMPackage -Name ($pkg.Name)
    foreach ($cmPkg in $cmPkgObj) {
        $cmProgObj = Get-CMProgram -Package $cmPkg

        foreach ($prog in $cmProgObj) {
            Write-Output "$($cmPkg.Name), $($prog.ProgramName), $($prog.CommandLine)" 
            Write-Output "$($cmPkg.Name), $($prog.ProgramName), $($prog.CommandLine)" | out-file $pkgBkup -Append -Force
        }
    }
}
#>


$ErrorActionPreference = "Stop"
foreach ($app in $appCSV) {

    $cmAppObj = Get-CMApplication -Name ($app.localizedDisplayName)
    foreach ($cmApp in $cmAppObj) {
        $cmDepTypeObj = Get-CMDeploymentType -InputObject $cmApp

        $xml = $cmApp | Select SDMPackageXML -ExpandProperty SDMPackageXML | Select SDMPackageXML -ExpandProperty SDMPackageXML
        $deployType =[Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($XML)
        $installString = $deployType.DeploymentTypes.Installer.InstallCommandLine
        Write-Output "$($cmApp.LocalizedDisplayName), $($DT.LocalizedDisplayName), $installString" 
        Write-Output "$($cmApp.LocalizedDisplayName), $($DT.LocalizedDisplayName), $installString" | out-file $appBkup -Append -Force
    }
}

