# Set your variables
#$gpoName = "WS_Visual_Messaging_Automation_Test"
$gpoName = "WS_Visual_Messaging_Automation_Test"

# Check if GPO exists
$gpo = Get-GPO -Name $gpoName -ErrorAction Stop
$gpoGuid = $gpo.ID.ToString("B").ToUpper()
$gpoGuid