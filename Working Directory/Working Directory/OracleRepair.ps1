<# Check for Oracle 19c Client


/#>

### Functions


# Test .Reg Key File
Function Test-RegFile ($regFilePath, $outFileName) {

    # Define the path to the .reg file
    #$regFilePath = "C:\CHOA\instantodbc.reg"


    # Check if the file exists
    if (!(Test-Path $regFilePath)) {
       Write-Host "The specified .reg file does not exist: $regFilePath" -ForegroundColor Red
       #exit
    }
    # Read the .reg file content
    $regContent = Get-Content $regFilePath
    # Array to store results
    $results = @()
    # Function to normalize paths inside registry values
    function Normalize-RegistryPathValue($value) {
       if ($value -match ".*\\\\.*") {  # Only apply if the value contains double backslashes (likely a path)
           return $value -replace "\\\\", "\"
       }
       return $value
    }
    # Variable to store the current registry key
    $currentKey = ""
    # Loop through each line in the file
    foreach ($line in $regContent) {
       # Ignore blank lines and comments
       if ($line -match "^\s*;|^\s*$") {
           continue
       }
       # Detect a registry key (lines enclosed in square brackets)
       if ($line -match "^\[(.*)\]$") {
           $currentKey = $matches[1] -replace "\\\\", "\"
       }
       # Detect a registry value (format: "ValueName"="Data")
       elseif ($line -match '^\s*"(.+?)"\s*=\s*"(.*)"$') {
           $valueName = $matches[1]
           $expectedData = Normalize-RegistryPathValue($matches[2])  # Normalize expected path value
           # Default status
           $status = "MISSING KEY"
           # Check if the registry key exists
           if (Test-Path "Registry::$currentKey") {
               $existingValue = Get-ItemProperty -Path "Registry::$currentKey" -Name $valueName -ErrorAction SilentlyContinue
               if ($existingValue) {
                   $actualValue = Normalize-RegistryPathValue($existingValue.$valueName)  # Normalize actual path value
                   if ($actualValue -eq $expectedData) {
                       $status = "MATCH"
                   } else {
                       $status = "MISMATCH (Expected: $expectedData, Found: $actualValue)"
                   }
               } else {
                   $status = "MISSING VALUE"
               }
           }
           # Store the result in an array
           $results += [PSCustomObject]@{
               RegistryKey = $currentKey
               ValueName   = $valueName
               Status      = $status
           }
       }
    }
    # Output the results array
    $results #| Format-Table -AutoSize
    # Export the results to a CSV file if needed
    $results | Export-Csv -Path "C:\CHOA\$outFileName.csv" -NoTypeInformation
}

# Check for C:\Oracle Directory
Function Test-OracleInstallPath ($oPath) {
    If (Test-path $oPath) {
        Return ((Get-ChildItem C:\oracle\product).Name)
    }
}

# Check for Oracle Directory in Program Files / Program Files (x86)
Function Test-OracleProgFiles {
    If (Test-Path 'C:\Program Files\Oracle') {
        $ora64 = $true
    }
    If (Test-Path 'C:\Program Files (x86)\Oracle') {
        $ora86 = $true
    }
    If (($ora64 -eq $true) -and ($ora86 -ne $true)) {
        return "x64"
    }elseif (($ora64 -ne $true) -and ($ora86 -eq $true)) {
        return "x86"
    }elseif (($ora64 -eq $true) -and ($ora86 -eq $true)) {
        return "x64 & x86"
    }
}

# Check TNS_ADMIN variable
Function Check-TNS_ADMINvar {
    $tAP = $env:TNS_ADMIN
    if ($null -eq $tAP) {
        Return "Not Present"
    }else{
        Return $tAP
    }
}

# Check PATH variable for v18 and v19
Function Check-PATHvar {
    $oracleSysPaths = @()
    $sysPaths = $Env:PATH.Split(";")
    foreach ($sysPath in $sysPaths) {
        if ($sysPath -like "*oracle*") {
            $oracleSysPaths += $sysPath
        }
    }
    Return $oracleSysPaths
}

# Check Database ConnectivityFunction Test-ODBCDBconn {$var1 = [string][char[]][int[]]("70.83.95.84.69.83.84".Split(".")) -replace " "$var2 = [string][char[]][int[]]("70.83.95.116.101.115.116.48.49".Split(".")) -replace " "$var3 = [string][char[]][int[]]("75.73.68.83".Split(".")) -replace " "$checkFile = "C:\CHOA\OracleTest.txt"$Text   = "Connected to"$sCommand = @"EXIT"@    $sCommand | C:\oracle\product\19.0.0\client_instant_64\sqlplus -L $var1/$var2@$var3 >$checkFile    if (Select-String -Path $checkFile -Pattern $Text) {        Return 0    } else {        Return 1    }
}

# Check for CHOA registry key (PSADT) / Installed From Software Center
 Function Check-SCCMInstall {
    If (Test-Path 'HKLM:\SOFTWARE\InstalledApps\Oracle America_Oracle Client_19c') {
        Return 1
    }
}

### /Functions

$oraclePath = Test-OracleInstallPath "C:\oracle"
$oracleProgFiles = Test-OracleProgFiles
$tnsVar = Check-TNS_ADMINvar
$sysVar = Check-PATHvar
$sccmInstall = Check-SCCMInstall
$x86Reg = Test-RegFile "C:\CHOA\instantodbc_x86.reg" "x86reg"
$x64Reg = Test-RegFile "C:\CHOA\instantodbc_x64.reg" "x64Reg"
$connectionTest = Test-ODBCDBconn

