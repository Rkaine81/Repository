Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
function Show-GUI {
   $Form = New-Object System.Windows.Forms.Form
   $Form.Text = "Configuration Manager"
   $Form.Size = New-Object System.Drawing.Size(400, 250)
   $Form.StartPosition = "CenterScreen"
   # Build Type Label
   $BuildTypeLabel = New-Object System.Windows.Forms.Label
   $BuildTypeLabel.Text = "Build Type:"
   $BuildTypeLabel.Location = New-Object System.Drawing.Point(10, 20)
   $BuildTypeLabel.Size = New-Object System.Drawing.Size(80, 20)
   $Form.Controls.Add($BuildTypeLabel)
   # Build Type ComboBox
   $BuildTypeComboBox = New-Object System.Windows.Forms.ComboBox
   $BuildTypeComboBox.Location = New-Object System.Drawing.Point(100, 20)
   $BuildTypeComboBox.Size = New-Object System.Drawing.Size(250, 20)
   $BuildTypeComboBox.Items.AddRange(@("Standard", "Display PC", "SSO"))
   $Form.Controls.Add($BuildTypeComboBox)
   # Location Label
   $LocationLabel = New-Object System.Windows.Forms.Label
   $LocationLabel.Text = "Location:"
   $LocationLabel.Location = New-Object System.Drawing.Point(10, 60)
   $LocationLabel.Size = New-Object System.Drawing.Size(80, 20)
   $Form.Controls.Add($LocationLabel)
   # Location ComboBox
   $LocationComboBox = New-Object System.Windows.Forms.ComboBox
   $LocationComboBox.Location = New-Object System.Drawing.Point(100, 60)
   $LocationComboBox.Size = New-Object System.Drawing.Size(250, 20)
   $LocationComboBox.Items.AddRange(@("Office", "Home", "Hospital"))
   $Form.Controls.Add($LocationComboBox)
   # Submit Button
   $SubmitButton = New-Object System.Windows.Forms.Button
   $SubmitButton.Text = "Submit"
   $SubmitButton.Location = New-Object System.Drawing.Point(100, 100)
   $SubmitButton.Add_Click({
       if ($BuildTypeComboBox.SelectedItem -and $LocationComboBox.SelectedItem) {
           [System.Windows.Forms.MessageBox]::Show("Build Type: $($BuildTypeComboBox.SelectedItem)`nLocation: $($LocationComboBox.SelectedItem)")
           $Form.Close()
           # Set Task Sequence Variables
           $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment
           $TSEnvironment.Value("BuildType") = $BuildTypeComboBox.SelectedItem
           $TSEnvironment.Value("Location") = $LocationComboBox.SelectedItem
       } else {
           [System.Windows.Forms.MessageBox]::Show("Please select both a build type and a location.")
       }
   })
   $Form.Controls.Add($SubmitButton)
   $Form.ShowDialog()
}
Show-GUI