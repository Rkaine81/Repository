#Output Qualys Data
$qualysHealth = & "$env:ProgramFiles\qualys\qualysagent\QualysAgentHealthCheck.exe"
$fullFilePath = ($qualysHealth | where {$_ -like "Detailed*"}).split(":")[-1]
$fullFilePath = "C:$fullFilePath"
if (test-path $fullFilePath) {
    $qualysStatus = get-content -Path $fullFilePath | ConvertFrom-Json
}

#Compliance Work Here

$qualysStatus.OverallHealth


#Cleanup
$filePath = $fullFilePath.SubString(0, $fullFilePath.LastIndexOf("\"))
Remove-Item -Recurse $filePath -Force