if (!(Test-Path C:\Oracle)) {
    New-Item -ItemType Directory -Path C:\ -Name "Oracle"
}else{
    $oracleExists = $true
    If (Test-path "C:\oracle\product\18.0.0") {
        Rename-Item "C:\oracle" "C:\oracle.old" -Force
        New-Item -ItemType Directory -Path C:\ -Name "Oracle"
        If (Test-path "C:\oracle") {
            $newOracleDirCreated = $true
        }else{
            $newOracleDirCreated = $false
            #Change this to write-log
            Write-Output "A directory could not be created at C:\Oracle."
            Exit 1
        }
    }
}



if (!(Test-Path C:\OracleClient)) {
    New-Item -ItemType Directory -Path C:\ -Name "OracleClient"
}else{
    $oracleInstallerExists = $true
}

