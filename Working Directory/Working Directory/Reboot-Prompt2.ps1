Add-Type -AssemblyName System.Windows.Forms
$timeoutSeconds = 10
$defaultAction = 'Now'
$choice = $null
# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Reboot Required"
$form.Size = New-Object System.Drawing.Size(360, 150)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true
$label = New-Object System.Windows.Forms.Label
$label.Text = "Do you want to reboot now or wait 30 minutes?"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(30, 20)
$form.Controls.Add($label)
$btnNow = New-Object System.Windows.Forms.Button
$btnNow.Text = "Reboot Now"
$btnNow.Location = New-Object System.Drawing.Point(40, 60)
$btnNow.Size = New-Object System.Drawing.Size(100, 30)
$btnNow.Add_Click({
   $global:choice = "Now"
   $timer.Stop()
   $form.Close()
})
$form.Controls.Add($btnNow)
$btnLater = New-Object System.Windows.Forms.Button
$btnLater.Text = "Wait 30 Minutes"
$btnLater.Location = New-Object System.Drawing.Point(180, 60)
$btnLater.Size = New-Object System.Drawing.Size(120, 30)
$btnLater.Add_Click({
   $global:choice = "Later"
   $timer.Stop()
   $form.Close()
})
$form.Controls.Add($btnLater)
# Timer fallback
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $timeoutSeconds * 1000
$timer.Add_Tick({
   $timer.Stop()
   if (-not $global:choice) {
       $global:choice = $defaultAction
       $form.Close()
   }
})
$timer.Start()
# Show the form
$form.ShowDialog() | Out-Null
# Ensure fallback choice if still null (paranoia fallback)
if (-not $choice) {
   $choice = $defaultAction
}
# Decision
switch ($choice) {
   'Now' {
       Write-Output "Action: Reboot Now"
       #Restart-Computer -Force
   }
   'Later' {
       Write-Output "Action: Wait 30 minutes, then reboot"
       Start-Sleep -Seconds 10
       Write-Output "Reboot"
       #Restart-Computer -Force
   }
}