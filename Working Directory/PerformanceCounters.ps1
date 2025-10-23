

Get-Counter '\NUMA Node Memory(_Total)\Total MBytes'
Get-Counter '\Memory\Available MBytes'



Get-Counter '\Processor(_Total)\% Processor Time'
Get-Counter '\Processor Performance(*)\Processor Frequency'
Get-Counter '\Processor Performance(*)\Processor Frequency'


Get-Counter -ListSet *memory* | Select-Object -ExpandProperty  Counter

Get-Counter -ListSet *Processor* | Select-Object -ExpandProperty  Counter

(Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

((Get-Counter '\Memory\% Committed Bytes In Use').CounterSamples.CookedValue)
(Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
(Get-Counter '\NUMA Node Memory(_Total)\Total MBytes').CounterSamples.CookedValue

Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select Average

Get-WmiObject Win32_Processor | Select LoadPercentage | Format-List



$totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
while($true) {
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $cpuTime = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
    $date + ' > CPU: ' + $cpuTime.ToString("#,0.000") + '%, Avail. Mem.: ' + $availMem.ToString("N0") + 'MB (' + (104857600 * $availMem / $totalRam).ToString("#,0.0") + '%)'
    Start-Sleep -s 2
}



Get-Counter -ComputerName localhost '\Process(*)\% Processor Time' `
    | Select-Object -ExpandProperty countersamples `
    | Select-Object -Property instancename, cookedvalue `
    | Sort-Object -Property cookedvalue -Descending | Select-Object -First 20 `
    | ft InstanceName,@{L='CPU';E={($_.Cookedvalue/100).toString('P')}} -AutoSize

$psstats = Get-Counter -ComputerName . '\Process(*)\% Processor Time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty countersamples | %{New-Object PSObject -Property @{ComputerName=$_.Path.Split('\')[2];Process=$_.instancename;CPUPct=("{0,4:N0}%" -f $_.Cookedvalue);CookedValue=$_.CookedValue}} | ?{$_.CookedValue -gt 0}| Sort-Object @{E='ComputerName'; A=$true },@{E='CookedValue'; D=$true },@{E='Process'; A=$true }
$psstats | ft @{E={"{0,25}" -f $_.Process};L="ProcessName"},CPUPct -AutoSize -GroupBy ComputerName -HideTableHeaders




while ($true) {
     [int]$date = get-date -Uformat %s
     #$exportlocation = New-Item -type file -path "c:\$date.csv"
     Get-Counter -Counter "\Processor(_Total)\% Processor Time" | % {$_} #| Out-File $exportlocation
     start-sleep -s 5
}



if (test-path hkcu:\software\cpu) {
    $cpu = (get-itemproperty hkcu:\software\cpu).cpu
}
$cpu = @($cpu + (Get-CimInstance win32_processor).loadpercentage)[-10..-1]
if (! (test-path hkcu:\software\cpu)) {
    new-item hkcu:\software\cpu > $null
}
set-itemproperty hkcu:\software\cpu cpu $cpu -type multistring
($cpu | measure -average).average

$FormatEnumerationLimit = 10
icm . { get-itemproperty hklm:\software\cpu -ea 0 | select cpu }