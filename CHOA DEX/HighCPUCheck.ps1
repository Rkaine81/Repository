# Get the current CPU usage
$cpuUsage = Get-WmiObject Win32_PerfFormattedData_PerfOS_Processor | Select-Object -ExpandProperty PercentProcessorTime
# Format CPU usage percentage
$formattedCpuUsage = "{0:N2}" -f $cpuUsage
# Check if CPU usage is over 80%
if ($cpuUsage -gt 30) {
   Write-Host "High CPU utilization detected: $($formattedCpuUsage)%"
} else {
   Write-Host "CPU utilization is normal: $($formattedCpuUsage)%"
}


# Define the threshold for high CPU utilization (e.g., 80%)
$threshold = 80
# Get the current CPU usage counter
$cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
# Check if CPU usage is above the threshold
if ($cpuUsage -gt $threshold) {
   Write-Host "High CPU utilization detected: $($cpuUsage)%"
} else {
   Write-Host "CPU utilization is normal: $($cpuUsage)%"
}



# Define the threshold for high CPU utilization (e.g., 80%)
$threshold = 80
# Get the current time and calculate the time 10 minutes ago
$currentTime = Get-Date
$targetTime = $currentTime.AddMinutes(-10)
# Get the CPU usage counter at the target time
$cpuUsage = (Get-Counter -Counter '\Processor(_Total)\% Processor Time' -SampleInterval 10 -MaxSamples 1 -Continuous).CounterSamples | Where-Object { $_.Timestamp -lt $targetTime } | Select-Object -ExpandProperty CookedValue
# Check if CPU usage is above the threshold
if ($cpuUsage -gt $threshold) {
   Write-Host "High CPU utilization detected 10 minutes ago: $($cpuUsage)%"
} else {
   Write-Host "CPU utilization was normal 10 minutes ago: $($cpuUsage)%"
}

