$result = Get-WinEvent -FilterHashtable @{LogName="Application";Id=1001} | ForEach-Object {
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

$todaysEvents = $result | where { (($today - ($_.EventDate)).Days -eq 1) -and ($_.EventName -eq "APPCRASH")}

If ($null -eq $todaysEvents) {
    return $true
}else{
    return $false
}
