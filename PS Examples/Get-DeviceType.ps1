$TSvars1 = @{}

$DesktopChassisTypes = @("3","4","5","6","7","13","15","16","35")
$LatopChassisTypes = @("8","9","10","11","12","14","18","21","30","31")
$ServerChassisTypes = @("23")

function Get-SystemEnclosureInfo {

    $chassi = gwmi -Class 'Win32_SystemEnclosure' 

    $chassi.ChassisTypes | foreach {

        if($TSvars1.ContainsKey("IsDesktop")) {
            $TSvars1["IsDesktop"] = [string]$DesktopChassisTypes.Contains($_.ToString())
        }
        else {
            $TSvars1.Add("IsDesktop", [string]$DesktopChassisTypes.Contains($_.ToString()))
        }

        if($TSvars1.ContainsKey("IsLaptop")) {
            $TSvars1["IsLaptop"] = [string]$LatopChassisTypes.Contains($_.ToString())
        }
        else {
            $TSvars1.Add("IsLaptop", [string]$LatopChassisTypes.Contains($_.ToString()))
        }
    }
}

Get-SystemEnclosureInfo

$TSvars1.IsDesktop
$TSvars1.IsLaptop