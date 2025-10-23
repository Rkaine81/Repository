Import-Module sqlserver

$SqlServer    = 'dcvwp-sccmdb01' # SQL Server instance (HostName\InstanceName for named instance)
$Database     = 'CM_P01'      # SQL database to connect to 

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

$updates=Get-CMSoftwareUpdate -fast | ? {$_.NumMissing -eq 1 -and $_.IsDeployed -eq $True -and $_.CustomSeverity -eq 0 -and $_.IsExpired -eq $false -and $_.IsSuperseded -eq $false}

# Initialize an array to store the report

$report = @()

# Loop through each update

foreach ($update in $updates) {

# Query the CM_XXX database to get device names for the update

$sqlQuery = @"

select sys.name0 as 'Computer Name'

from v_updateinfo ui

inner join v_UpdateComplianceStatus ucs on ucs.ci_id=ui.ci_id

join v_CICategories_All catall2 on catall2.CI_ID=UCS.CI_ID

join v_CategoryInfo catinfo2 on catall2.CategoryInstance_UniqueID = catinfo2.CategoryInstance_UniqueID and catinfo2.CategoryTypeName='UpdateClassification'

join v_R_System sys on sys.resourceid=ucs.resourceid

where ucs.status='2' -- required

AND (ui.CI_ID='$($update.CI_ID)')

GROUP BY sys.name0

order by sys.name0

"@

        # Invoke the SQL query

        $devicesForUpdate = Invoke-Sqlcmd -ServerInstance "SERVER" -Database "CM_XXX" -Query $sqlQuery -ErrorAction Stop
        #Invoke-Sqlcmd -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True; Encrypt=False; TrustServerCertificate=True" -Query "$Query" 

        # Add the results to the report

        foreach ($device in $devicesForUpdate) {

            $report += [PSCustomObject]@{

            'UpdateName' = $update.LocalizedDisplayName

            'DeviceName' = $device.'Computer Name'

        }

    }

}

# Output the report

$report | Sort-Object DeviceName | ft DeviceName, UpdateName