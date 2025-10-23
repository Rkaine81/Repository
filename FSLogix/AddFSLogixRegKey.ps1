#Create registry path if it doesn't exist. Modify entry value. 
#Example: Write-RegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" "DWord" "1"
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


$CREGKEY = "HKLM:\Software\fslogix\apps\CleanupInvalidSessions"
$CREGVAL = "CleanupInvalidSessions"
$CREGTYPE = "DWord"
$CREGDATA = "0"

Write-RegKey $CREGKEY $CREGVAL $CREGTYPE $CREGDATA