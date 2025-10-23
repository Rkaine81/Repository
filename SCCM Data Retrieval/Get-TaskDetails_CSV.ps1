$SiteCode = "P01" # Site code 
$ProviderMachineName = "DCVWP-SCCMAP01.choa.org" # SMS Provider machine name

$initParams = @{}

if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams


# Specify the Task Sequence name or ID
$TaskSequenceName = "Deploy Windows 11"

# Get the Task Sequence
$TaskSequence = Get-CMTaskSequence | Where-Object { $_.Name -eq $TaskSequenceName }

if ($TaskSequence) {
    # Export Task Sequence details
    $TaskSequenceDetails = Get-CMTaskSequenceStep -TaskSequencePackageId $TaskSequence.PackageID | where {$_.Enabled -eq "True"}

    # Save to a CSV file
    $OutputFile = "C:\CHOA\SCCM_TaskSequence_Documentation.csv"
    $TaskSequenceDetails | Select-Object Name, Description | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

    Write-Host "Task Sequence documentation saved to $OutputFile"
} else {
    Write-Host "Task Sequence '$TaskSequenceName' not found."
}
