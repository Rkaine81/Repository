Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Log Viewer"
$form.Size = New-Object System.Drawing.Size(800, 600)
# Create a DataGridView for displaying log entries
$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Size = New-Object System.Drawing.Size(780, 500)
$dataGridView.Location = New-Object System.Drawing.Point(10, 40)
$dataGridView.AutoGenerateColumns = $true
# Create a TextBox for filtering log entries
$filterTextBox = New-Object System.Windows.Forms.TextBox
$filterTextBox.Size = New-Object System.Drawing.Size(200, 20)
$filterTextBox.Location = New-Object System.Drawing.Point(10, 10)
# Create a Button to apply the filter
$filterButton = New-Object System.Windows.Forms.Button
$filterButton.Text = "Filter"
$filterButton.Size = New-Object System.Drawing.Size(75, 23)
$filterButton.Location = New-Object System.Drawing.Point(220, 8)
$logEntries = @()
# Add controls to the form
$form.Controls.Add($dataGridView)
$form.Controls.Add($filterTextBox)
$form.Controls.Add($filterButton)
# Function to parse text-based log content and return an array of log entries
function Get-TextLogEntries {
   param (
       [string]$logFilePath
   )
   $entries = @()
   $files = Get-ChildItem -Path $logFilePath -File -Recurse
   foreach ($file in $files) {
       $lines = Get-Content -Path $file.FullName
       foreach ($line in $lines) {
           if ($line -match "(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}).*(Error|Warning|Information):(.*)") {
               $entries += [pscustomobject]@{
                   Timestamp = [datetime]$matches[1]
                   Level = $matches[2]
                   Message = $matches[3].Trim()
                   Source = $file.FullName
               }
           }
       }
   }
   return $entries
}
# Function to get event log entries
function Get-EventLogEntries {
   param (
       [string]$logName
   )
   $entries = @()
   $logs = Get-WinEvent -LogName $logName -ErrorAction SilentlyContinue | Select-Object -Property TimeCreated, LevelDisplayName, Message
   foreach ($log in $logs) {
       $entries += [pscustomobject]@{
           Timestamp = $log.TimeCreated
           Level = $log.LevelDisplayName
           Message = $log.Message.Trim()
           Source = $logName
       }
   }
   return $entries
}
# Function to load log files
function Load-Logs {
   $logFiles = @(
       "C:\DeviceHealthLogs\SystemInfo.txt",
       "C:\DeviceHealthLogs\InstalledPrograms.txt",
       "C:\DeviceHealthLogs\NetworkConfig.txt",
       "C:\DeviceHealthLogs\DiskInfo.txt",
       "C:\DeviceHealthLogs\WindowsUpdateLog.txt",
       "C:\DeviceHealthLogs\DriverInfo.txt",
       "C:\DeviceHealthLogs\BootTime.txt",
       "C:\DeviceHealthLogs\DefenderLog.txt",
       "C:\DeviceHealthLogs\ApplicationCrashes.csv",
       "C:\DeviceHealthLogs\MECMLogs"
   )
   $logEntriesTemp = @()
   # Get text-based log entries
   foreach ($logFile in $logFiles) {
       if (Test-Path $logFile) {
           $logEntriesTemp += Get-TextLogEntries -logFilePath $logFile
       } elseif (Test-Path -PathType Container $logFile) {
           $files = Get-ChildItem -Path $logFile -Recurse
           foreach ($file in $files) {
               $logEntriesTemp += Get-TextLogEntries -logFilePath $file.FullName
           }
       }
   }
   # Get event log entries
   $logEntriesTemp += Get-EventLogEntries -logName "System"
   $logEntriesTemp += Get-EventLogEntries -logName "Application"
   $logEntriesTemp += Get-EventLogEntries -logName "Security"
   # Sort log entries by timestamp
   $logEntriesTemp = $logEntriesTemp | Sort-Object -Property Timestamp
   return $logEntriesTemp
}
# Load logs and update the DataGridView
function Load-LogsAndUpdateGUI {
   $logEntries = Load-Logs
   # Update the DataGridView with the loaded logs
   $dataGridView.Invoke([Action]{
       $dataGridView.DataSource = $logEntries
   })
}
# Define the filter button click event
$filterButton.Add_Click({
   $filter = $filterTextBox.Text
   if ($filter) {
       $filteredEntries = $logEntries | Where-Object { $_.Message -like "*$filter*" -or $_.Level -like "*$filter*" -or $_.Source -like "*$filter*" }
       $dataGridView.DataSource = $filteredEntries
   } else {
       $dataGridView.DataSource = $logEntries
   }
})
# Highlight errors and warnings
$dataGridView.add_DataBindingComplete({
   param ($sender, $e)
   foreach ($row in $dataGridView.Rows) {
       if ($row.Cells["Level"].Value -eq "Error") {
           $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::Red
       } elseif ($row.Cells["Level"].Value -eq "Warning") {
           $row.DefaultCellStyle.BackColor = [System.Drawing.Color]::Yellow
       }
   }
})
# Show the form and start loading logs
$form.Add_Shown({
   $form.Activate()
   Load-LogsAndUpdateGUI
})
[void]$form.ShowDialog()