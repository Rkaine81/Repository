# Setting variables
$PCSystemType = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object PCSystemType).PCSystemType
$ComputerModel = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object Model).Model
$SerialNumber = (Get-WmiObject -Class Win32_BIOS | Select-Object SerialNumber).SerialNumber
$adapter = Get-NetAdapter | Where {$_.Name -Match "Ethernet 2"}

# IF sytem is Surface Laptop 4
  if ($ComputerModel -match "Surface Laptop 4")
     { $OSDComputerName = "SL4" + $SerialNumber
      $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
      $TSEnv.Value("OSDComputerName") = "$OSDComputerName" }

# IF sytem is Surface Laptop 5
  if ($ComputerModel -match "Surface Laptop 5")
     { $OSDComputerName = "SL5" + $SerialNumber
      $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
      $TSEnv.Value("OSDComputerName") = "$OSDComputerName" }

# IF system is HP
$SerialNumberResult = $SerialNumber.Substring(3)

if (($PCSystemType -match "2") -and ($ComputerModel -match "HP*"))
    { $OSDComputerName = "CHOA-HPL" + $SerialNumberResult
     $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
     $TSEnv.Value("OSDComputerName") = "$OSDComputerName" }

if (($PCSystemType -match "1") -and ($ComputerModel -match "HP*"))
    { $OSDComputerName = "CHOA-HPD" + $SerialNumberResult
     $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
     $TSEnv.Value("OSDComputerName") = "$OSDComputerName" }

# IF system is Hyper-V VM
if  ($ComputerModel -match "Virtual Machine") 
    {$MacAddressResult = $adapter.MacAddress.Replace("-", "") 
     $OSDComputerName = "CHOA-VM" + $MacAddressResult.substring(4)
     $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
     $TSEnv.Value("OSDComputerName") = "$OSDComputerName" }

# IF system is VMWare
if  ($ComputerModel -match "VMware Virtual Platform") 
     {$MacAddressResult = $adapter.MacAddress.Replace("-", "") 
     $OSDComputerName = "CHOA-VMW" + $MacAddressResult.substring(5)
     $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
     $TSEnv.Value("OSDComputerName") = "$OSDComputerName" }


# IF system is VMWare Fusion
if  ($ComputerModel -match "VMware7.1*") 
     {$MacAddressResult = $adapter.MacAddress.Replace("-", "") 
     $OSDComputerName = "CHOA-VMWF" + $MacAddressResult.substring(6)
     $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
     $TSEnv.Value("OSDComputerName") = "$OSDComputerName" }


# IF system is Parallels VM (Apple Mac)
if  ($ComputerModel -match "Parallels Virtual Platform") 
     {$MacAddressResult = $adapter.MacAddress.Replace("-", "") 
     $OSDComputerName = "CHOA-PRL" + $MacAddressResult.substring(5)
     $TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
     $TSEnv.Value("OSDComputerName") = "$OSDComputerName" }



