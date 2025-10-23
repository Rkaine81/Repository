<#
#Run Cisco Support Utility
$ipSupportTool = Get-ChildItem -Path "C:\Program Files\Cisco\AMP" -Filter ipsupporttool.exe -Recurse -ErrorAction SilentlyContinue -Force
& $ipSupportTool.FullName -o "C:\CHOA"
Start-Sleep 60

#Extract Archive
$zip = Get-ChildItem -Path "C:\CHOA" -Filter "CiscoAMP_Support_Tool*" -Recurse -ErrorAction SilentlyContinue -Force
Expand-Archive $zip.FullName -DestinationPath c:\CHOA\AMP
Start-Sleep 20

#Get XML Data
$xmlFile = Get-ChildItem -Path "C:\CHOA\AMP\Program Files\Cisco\AMP" -Filter local.xml -Recurse -ErrorAction SilentlyContinue -Force
[xml]$data = Get-Content $xmlFile.FullName
#>

<# XML sections
$data.config.agent
$data.config.install.switches
$data.config.janus
$data.config.orbital
$data.config.proxy
/#>



function Convert-UnixTimestampToEST {
   param (
       [Parameter(Mandatory=$true)]
       [int]$Timestamp
   )
   # Convert Unix timestamp to DateTime
   $dateTime = [System.DateTimeOffset]::FromUnixTimeSeconds($Timestamp).DateTime
   # Convert to Eastern Standard Time (EST)
   $timeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Eastern Standard Time")
   $dateTimeEST = [System.TimeZoneInfo]::ConvertTime($dateTime, $timeZone)

   # Output the result as string
   # return $dateTimeEST.ToString("yyyy-MM-dd HH:mm:ss")

   # Output the result as date object
   return $dateTimeEST
}
# Example usage
#$unixTimestamp = 1718743722
#$result = Convert-UnixTimestampToEST -Timestamp $unixTimestamp
#$result



#Get XML Data
$xmlFile = Get-ChildItem -Path "C:\Program Files\Cisco\AMP" -Filter local.xml -Recurse -ErrorAction SilentlyContinue -Force
[xml]$data = Get-Content $xmlFile.FullName

#Check Data

$agentRegistered = $data.config.agent.agent_registered

$agentDisabled = $data.config.agent.agent_disabled

$unixTimestamp = $data.config.agent.engine.tetra.lastupdate
$lastUpdateResult = Convert-UnixTimestampToEST -Timestamp $unixTimestamp
write-output "The last update result was:                $lastUpdateResult."

$unixTimestamp = $data.config.agent.engine.tetra.lastsuccesstime
$lastUpdateSuccessTimeResult = Convert-UnixTimestampToEST -Timestamp $unixTimestamp
write-output "The last update success time result was:   $lastUpdateSuccessTimeResult."

$unixTimestamp = $data.config.agent.engine.tetra.lastupdatechecked
$lastUpdateCheckedResult = Convert-UnixTimestampToEST -Timestamp $unixTimestamp
write-output "The last update checked result was:        $lastUpdateCheckedResult."




