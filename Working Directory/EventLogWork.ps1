$result = Get-WinEvent -FilterHashtable @{LogName="System";Id=1030} | ForEach-Object {
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

If ($null -eq $result) {
    Write-Output "GP.ini OK."
    #return $true
}else{
    Write-Output "GP.ini Corrupt."
    #return $false
}






$result = Get-WinEvent -FilterHashtable @{LogName="System";Id=1030} | ForEach-Object {
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

$today = get-date

$currentEvents2 = $result | where { (($today - ($_.EventDate)).Days -lt 630)}

If ($null -eq $currentEvents2) {
    return $true
}else{
    return $false
}




($currentEvents1.count) -ge 1

<#
$today = get-date
foreach ($obj in $result) {
    ($today - ($obj.eventdate)).Days
}
#>