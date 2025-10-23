If (!(test-path "C:\OracleClient\stage\products.xml")) {
    Expand-Archive -Path ".\Oracle19c.zip" -DestinationPath "C:\OracleClient" -Force
}else{
    $oracleVersionDetails = ([xml](get-content "C:\OracleClient\stage\products.xml")).PRD_LIST.TL_LIST.COMP[0].VER
    If ($oracleVersionDetails -eq "19.0.0.0.0") {
        If (test-path C:\OracleClient\setup.exe) {
            Write-Output "The Oracle 19c client is already present."
        }else{
            Write-Output "Setup.exe not found.  Overwriting the current directory with the new installer."
            Expand-Archive -Path ".\Oracle19c.zip" -DestinationPath "C:\OracleClient" -Force
        }
    }else{
        Write-Output "An old installer is present. $oracleVersionDetails. This will be overwritten by the 19c installer."
        Expand-Archive -Path ".\Oracle19c.zip" -DestinationPath "C:\OracleClient" -Force
    }
    
} 




If (!(test-path "C:\OracleClient\setup.exe")) {
    write-output "Could not extract archive file."
    Exit 1
}

Start-Process -FilePath "cmd.exe" -ArgumentList "/c reg.exe import `"C:\OracleClient\instantodbc.reg`"" -Wait -passthru


$sysPaths = $Env:PATH.Split(";")
foreach ($sysPath in $sysPaths) {
    If ($sysPath -eq "C:\Oracle") {
        Write-Output "The System Path variable is aready set"
    }else{
    #add Try/Catch
        [Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";C:\Oracle", [EnvironmentVariableTarget]::Machine)
    }
}


if ($null -eq $env:TNS_ADMIN) {
    [Environment]::SetEnvironmentVariable("TNS_ADMIN", $Env:TNS_ADMIN + "\\choa-cifs\install\CM_P01\00_ToolsTestTemplates\AE\Oracle\TNSNames", [EnvironmentVariableTarget]::Machine)
}else{
    Write-Output "The TNS_ADMIN environment variable is already set."
    #Check the value and make sure it matches ours.   If not, overwrite
}



$var1 = [string][char[]][int[]]("70.83.95.84.69.83.84".Split(".")) -replace " "
$var2 = [string][char[]][int[]]("70.83.95.116.101.115.116.48.49".Split(".")) -replace " "
$var3 = [string][char[]][int[]]("75.73.68.83".Split(".")) -replace " "
$checkFile = "C:\CHOA\OracleTest.txt"
$Text   = "Connected to"
$sCommand = @"
EXIT
"@

$sCommand | sqlplus -L $var1/$var2@$var3 >$checkFile
 
if (Select-String -Path $checkFile -Pattern $Text) {
    Write-Output "Successfully connected to KIDS database."
} else {
    Write-Output "Failed to connect to KIDS database."
}


