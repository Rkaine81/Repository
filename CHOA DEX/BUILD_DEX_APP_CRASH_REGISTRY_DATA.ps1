
function Test-RegistryValue {

    param (

     [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,

    [parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Value
    )

    try {

        Get-ItemProperty -Path $Path -Name $Value -ErrorAction Stop | Out-Null
        return $true
    }

    catch {

    return $false

    }

}

Function Write-RegKey{
 
    Param(
        [Parameter(Mandatory=$true)]
        [string]$registryPath,
        [Parameter(Mandatory=$true)]
        [string]$regName,
        [Parameter(Mandatory=$true)]
        [string]$regType,
        [Parameter(Mandatory=$true)]
        [string]$regValue
    )
    

    $ErrorActionPreference = "SilentlyContinue" 
    Write-output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    Write-output "Checking for the Registry key: $registryPath\$regName."
    If(!(Test-RegistryValue $registryPath $regName)){Write-output "Attempting to write RegKey: $registryPath\$regName"}

    If(!(Test-Path $registryPath)){
        Write-output "Attempting to write RegKey: $registryPath."
        New-Item -Path $registryPath -Force
            If(Test-Path $registryPath){Write-output "RegKey: $registryPath exists."}else{Write-Output "Error: The reg key $registryPath could not be created."}
    }

    $WRCHECK = $null
    if (((Get-ItemProperty -Path $registryPath -Name $regName).$regname) -ne $regValue) {
        Write-Output "The Registry Value data does not match the required data value.  Settings the data value to: $regValue"
        New-ItemProperty -Path $registryPath -Name $regName -PropertyType $regType -Value $regValue -Force | Write-Output
        $WRCHECK = "1"
    }else{
        Write-output "The registry value is already set to $regValue."
    }


    if ($WRCHECK = "1"){
        if (((Get-ItemProperty -Path $registryPath -Name $regName).$regname) -eq $regValue) {
            Write-output "The Registry Value data is set to: $regValue"
        }else{
            Write-Output "Error: The registry value data could not be set for $regName."
        }
    }
    
}


$KEYS = "00", "01", "02", "03", "04", "05", "06"

foreach ($KEY in $KEYS) {

    $x = "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"

    foreach ($Y in $X) {
        $CREGKEY = "HKLM:\SOFTWARE\CHOA\DEX\APPCRASH\$KEY"
        $CREGVAL = $Y
        $CREGTYPE = "DWord"
        $CREGDATA = Get-Random 5

        Write-RegKey $CREGKEY $CREGVAL $CREGTYPE $CREGDATA
    }

}