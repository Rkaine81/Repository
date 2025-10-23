#Build JSON File
$qualysHealth = & "$env:ProgramFiles\qualys\qualysagent\QualysAgentHealthCheck.exe"
$fullFilePath = ($qualysHealth | where {$_ -like "Detailed*"}).split(":")[-1]
$fullFilePath = "C:$fullFilePath"
if (test-path $fullFilePath) {
    $qualysStatus = get-content -Path $fullFilePath | ConvertFrom-Json
}


#Cleanup
$filePath = $fullFilePath.SubString(0, $fullFilePath.LastIndexOf("\"))
Remove-Item -Recurse $filePath -Force


$mods = $qualysStatus.Modules
foreach ($mod in $mods) {
    if ($mod.Name -eq "SCA") {
        $health = $mod.ModuleHealth
    }
}

if (($health) -eq "SCA Health Good") {
    return $true
}else{
    return $false
}

