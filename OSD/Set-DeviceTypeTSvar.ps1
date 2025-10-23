$TSvars = @{}

function Get-DeviceType {

    If ($TSEnv.Value("IsDesktop") -eq "TRUE" -and $TSEnv.Value("IsVM") -eq "FALSE") {
        $TSvars.Add("DeviceType","Desktop")
    }elseif ($TSEnv.Value("IsLaptop") -eq "TRUE") {
        $TSvars.Add("DeviceType","Laptop")
    }elseif ($TSEnv.Value("IsVM") -eq "TRUE") {
        $TSvars.Add("DeviceType","Virtual Machine")
    }

}

$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment

Get-DeviceType

$TSvars.Keys |% {
    $tsenv.Value($_) = $TSvars[$_]
}
