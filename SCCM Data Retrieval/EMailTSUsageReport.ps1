
 
# Database info
$dataSource = 'mysqlserver\myinstance' # SQLServer\Instance
$database = 'CM_ABC' # Database name
$TimeInHours = '168' # 168 = 7 days
$OSDTaskSequences = "
    'Windows OS Deployment x86',
    'Windows OS Deployment x64'
    " # Name/s of your OSD Task Sequences
 
#Email params
$EmailParams = @{
    To         = 'Joe.Bloggs@contoso.com'
    From       = 'PowerShell@contoso.com'
    Smtpserver = 'myexchangeserver'
    Subject    = "Operating System Deployment Weekly Report $(Get-Date -Format dd-MMM-yyyy)"
}
 
$results = @()
 
$connectionString = "Server=$dataSource;Database=$database;Integrated Security=SSPI;"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
 
$Query = "
    select distinct tes.ResourceID
    from vSMS_TaskSequenceExecutionStatus tes
    inner join v_TaskSequencePackage tsp on tes.PackageID = tsp.PackageID
    where tsp.Name in ($OSDTaskSequences)
    and DATEDIFF(hour,ExecutionTime,GETDATE()) < $TimeInHours
"
 
$command = $connection.CreateCommand()
$command.CommandText = $Query
$reader = $command.ExecuteReader()
$table = New-Object -TypeName 'System.Data.DataTable'
$table.Load($reader)
 
foreach ($ResourceID in $table.Rows.ResourceID)
{
    $Query = "
        Select (select top(1) convert(datetime,ExecutionTime,121)
        from vSMS_TaskSequenceExecutionStatus tes
        inner join v_R_System sys on tes.ResourceID = sys.ResourceID
        inner join v_TaskSequencePackage tsp on tes.PackageID = tsp.PackageID
        where tsp.Name in ($OSDTaskSequences)
        and DATEDIFF(hour,ExecutionTime,GETDATE()) < $TimeInHours
        and LastStatusMsgName = 'The task sequence execution engine started execution of a task sequence'
        and Step = 0
        and tes.ResourceID = $ResourceID
        order by ExecutionTime desc) as 'Start',
        (select top(1) convert(datetime,ExecutionTime,121)
        from vSMS_TaskSequenceExecutionStatus tes
        inner join v_R_System sys on tes.ResourceID = sys.ResourceID
        inner join v_TaskSequencePackage tsp on tes.PackageID = tsp.PackageID
        where tsp.Name in ($OSDTaskSequences)
        and DATEDIFF(hour,ExecutionTime,GETDATE()) < $TimeInHours
        and LastStatusMsgName = 'The task sequence execution engine successfully completed a task sequence'
        and tes.ResourceID = $ResourceID
        order by ExecutionTime desc) as 'Finish',
        (Select name0 from v_R_System sys where sys.ResourceID = $ResourceID) as 'ComputerName',
        (select Model0 from v_GS_Computer_System comp where comp.ResourceID = $ResourceID) as 'Model'
    "
    $command = $connection.CreateCommand()
    $command.CommandText = $Query
    $reader = $command.ExecuteReader()
    $table = New-Object -TypeName 'System.Data.DataTable'
    $table.Load($reader)
 
    if ($table.rows[0].Start.GetType().Name -eq 'DBNull')
    {
        $Start = ''
    }
    Else
    {
        $Start = $table.rows[0].Start
    }
 
    if ($table.rows[0].Finish.GetType().Name -eq 'DBNull')
    {
        $Finish = ''
    }
    Else
    {
        $Finish = $table.rows[0].Finish
    }
 
    #$table
    if ($Start -eq '' -or $Finish -eq '')
    {
        $diff = $null
    }
    else
    {
        $diff = $Finish-$Start
    }
 
    $PC = New-Object -TypeName psobject
    Add-Member -InputObject $PC -MemberType NoteProperty -Name ComputerName -Value $table.rows[0].ComputerName
    Add-Member -InputObject $PC -MemberType NoteProperty -Name StartTime -Value $table.rows[0].Start
    Add-Member -InputObject $PC -MemberType NoteProperty -Name FinishTime -Value $table.rows[0].Finish
    if ($Start -eq '' -or $Finish -eq '')
    {
        Add-Member -InputObject $PC -MemberType NoteProperty -Name DeploymentTime -Value ''
    }
    else
    {
        Add-Member -InputObject $PC -MemberType NoteProperty -Name DeploymentTime -Value $("$($diff.hours)" + ' hours ' + "$($diff.minutes)" + ' minutes')
    }
    Add-Member -InputObject $PC -MemberType NoteProperty -Name Model -Value $table.rows[0].Model
    $results += $PC
}
 
$results = $results | Sort-Object -Property ComputerName
 
$Query = "
    select sys.Name0 as 'ComputerName',
    tsp.Name 'Task Sequence',
    comp.Model0 as Model,
    tes.ExecutionTime,
    tes.Step,
    tes.GroupName,
    tes.ActionName,
    tes.LastStatusMsgName,
    tes.ExitCode,
    tes.ActionOutput
    from vSMS_TaskSequenceExecutionStatus tes
    left join v_R_System sys on tes.ResourceID = sys.ResourceID
    left join v_TaskSequencePackage tsp on tes.PackageID = tsp.PackageID
    left join v_GS_COMPUTER_SYSTEM comp on tes.ResourceID = comp.ResourceID
    where tsp.Name in ($OSDTaskSequences)
    and DATEDIFF(hour,ExecutionTime,GETDATE()) < $TimeInHours
    and tes.ExitCode not in (0,-2147467259)
    Order by tes.ExecutionTime desc
"
 
$command = $connection.CreateCommand()
$command.CommandText = $Query
$reader = $command.ExecuteReader()
$table = New-Object -TypeName 'System.Data.DataTable'
$table.Load($reader)
 
# Send html email
$style = "
<style>
body {
    color:#333333;
    font-family: ""Trebuchet MS"", Arial, Helvetica, sans-serif;}
    font-size: 10pt;
}
h1 {
    text-align:center;
}
h2 {
    border-top:1px solid #666666;
}
table {
    border-collapse: collapse;
    font-family: ""Trebuchet MS"", Arial, Helvetica, sans-serif;
}
th {
    font-size: 1.2em;
    text-align: left;
    padding-top: 5px;
    padding-bottom: 4px;
    background-color: #1FE093;
    color: #ffffff;
}
th, td {
    font-size: 1em;
    border: 1px solid #1FE093;
    padding: 3px 7px 2px 7px;
}
<style>
"
 
$body1 = $results |
Select-Object -Property ComputerName, StartTime, FinishTime , DeploymentTime, Model |
ConvertTo-Html -Head $style -Body "
<H2>OS Deployments This Week ($($results.Count))</H2>
 
" |
Out-String
 
$body2 = $table |
Select-Object -Property ComputerName, 'Task Sequence', Model, ExecutionTime, Step, GroupName, ActionName, LastStatusMsgName, ExitCode, ActionOutput |
ConvertTo-Html -Head $style -Body "
<H2>OS Deployment Errors This Week ($($table.Rows.Count))</H2>
 
" |
Out-String
 
$Body = $body1 + $body2
 
Send-MailMessage @EmailParams -Body $Body -BodyAsHtml
 
# Close the connection
$connection.Close()