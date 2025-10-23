#

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

$hour = (Get-Date).Hour
$today = Get-Date
$day = (Get-Date).DayOfWeek
$dayNum = switch ($DAY)
{
    "Sunday" {"00"}
    "Monday" {"01"}
    "Tuesday" {"02"}
    "Wednesday" {"03"}
    "Thursday" {"04"}
    "Friday" {"05"}
    "Saturday" {"06"}
}

$result = Get-WinEvent -FilterHashtable @{LogName="Application";Id=1001} | ForEach-Object {
    # convert the event to XML and grab the Event node
    $eventXml = ([xml]$_.ToXml()).Event
    # create an ordered hashtable object to collect all data
    # add some information from the xml 'System' node first
    $evt = [ordered]@{
        EventDate = [DateTime]$eventXml.System.TimeCreated.SystemTime
        Computer  = $eventXml.System.Computer
    }
    $eventXml.EventData.ChildNodes | ForEach-Object { $evt[$_.Name] = $_.'#text' }
    # output as PsCustomObject. This ensures the $result array can be written to CSV easily
    [PsCustomObject]$evt
}

$todaysEvents = $result | where { (($today - ($_.EventDate)).Days -eq 1) -and ($_.EventName -eq "APPCRASH")}
$errorResults = $todaysEvents.count

$CREGKEY = "HKLM:\SOFTWARE\CHOA\DEX\APPCRASH\$dayNum"
$CREGVAL = $hour
$CREGTYPE = "DWord"
$CREGDATA = $errorResults

Write-RegKey $CREGKEY $CREGVAL $CREGTYPE $CREGDATA