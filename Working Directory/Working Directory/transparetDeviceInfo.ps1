Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
# Placeholder functions
function Button1_Action { [System.Windows.Forms.MessageBox]::Show("Button 1 pressed") }
function Button2_Action { [System.Windows.Forms.MessageBox]::Show("Button 2 pressed") }
function Button3_Action { [System.Windows.Forms.MessageBox]::Show("Button 3 pressed") }
function Button4_Action { [System.Windows.Forms.MessageBox]::Show("Button 4 pressed") }
function Button5_Action { [System.Windows.Forms.MessageBox]::Show("Button 5 pressed") }
function Button6_Action { [System.Windows.Forms.MessageBox]::Show("Button 6 pressed") }
# System info
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.*" }).IPAddress | Select-Object -First 1
# Form setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "System Info"
$form.Size = New-Object System.Drawing.Size(400, 400)
$form.StartPosition = "CenterScreen"
$form.BackColor = 'Black'
$form.FormBorderStyle = 'FixedDialog'
$form.TopMost = $true
# Close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Close"
$closeButton.Size = New-Object System.Drawing.Size(60, 30)
$closeButton.Location = New-Object System.Drawing.Point(310, 10)
$closeButton.BackColor = 'DarkRed'
$closeButton.ForeColor = 'White'
$closeButton.FlatStyle = 'Flat'
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)
# System info label
$infoText = @"
User: $env:USERNAME
Device: $env:COMPUTERNAME
Domain: $env:USERDOMAIN
Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m
OS: $($os.Caption)
IP Address: $ip
"@
$label = New-Object System.Windows.Forms.Label
$label.Text = $infoText
$label.ForeColor = 'White'
$label.BackColor = 'Black'
$label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(20, 50)
$form.Controls.Add($label)
# Button layout
$buttonWidth = 100
$buttonHeight = 30
$buttonSpacingX = 20
$buttonSpacingY = 15
$startX = 40
$startY = 180
# Store labels and actual script blocks instead of function names
$buttonConfigs = @(
   @{ Label = "Action 1"; Action = { Button1_Action } },
   @{ Label = "Action 2"; Action = { Button2_Action } },
   @{ Label = "Action 3"; Action = { Button3_Action } },
   @{ Label = "Action 4"; Action = { Button4_Action } },
   @{ Label = "Action 5"; Action = { Button5_Action } },
   @{ Label = "Action 6"; Action = { Button6_Action } }
)
for ($i = 0; $i -lt $buttonConfigs.Count; $i++) {
   $config = $buttonConfigs[$i]
   $button = New-Object System.Windows.Forms.Button
   $button.Text = $config.Label
   $button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
   $x = $startX + (($i % 3) * ($buttonWidth + $buttonSpacingX))
   $y = $startY + [math]::Floor($i / 3) * ($buttonHeight + $buttonSpacingY)
   $button.Location = New-Object System.Drawing.Point($x, $y)
   $button.BackColor = 'DimGray'
   $button.ForeColor = 'White'
   $button.FlatStyle = 'Flat'
   # Proper closure capture
   $scriptBlock = $config.Action
   $button.Add_Click($scriptBlock)
   $form.Controls.Add($button)
}
# Show it
[void]$form.ShowDialog()