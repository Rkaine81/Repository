$SiteCode = "P01" 
$ProviderMachineName = "DCVWP-SCCMAP01.choa.org" 
$initParams = @{}
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}
Set-Location "$($SiteCode):\" @initParams

function Convert-DateString ([String]$Date, [String[]]$Format) {
 $result = New-Object DateTime

 $convertible = [DateTime]::TryParseExact(
    $Date,
    $Format,
    [System.Globalization.CultureInfo]::InvariantCulture,
    [System.Globalization.DateTimeStyles]::None,
    [ref]$result)

 if ($convertible) { $result }
}


$LimitingCollection = 'All Users and User Groups'
$RefreshType = 'Periodic'
$departments = Invoke-CMQuery -Name "Departments"
$departments = $departments.department

Foreach ($department in $departments) {
    $random = Get-Random -Minimum 0 -Maximum 59
    $tempDate = Convert-DateString -date '22:00:00' -Format 'HH:mm:ss'
    $DateTime = $tempDate.AddMinutes($random)
    $CMSched = New-CMSchedule -DayOfWeek Sunday -Start $DateTime 
    New-CMUserCollection -Name "$department" -LimitingCollectionName "$LimitingCollection" -RefreshType "$RefreshType" -RefreshSchedule $CMSched
    Add-CMUserCollectionQueryMembershipRule -CollectionName "$department" -QueryExpression "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where SMS_R_User.department like '$department'" -RuleName "$department"
}