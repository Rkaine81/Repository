$RootOU = "OU=Workstations2,DC=CHOA,DC=ORG"
$OUs = Get-ADOrganizationalUnit -Filter * -SearchBase $RootOU | Select-Object -ExpandProperty DistinguishedName
if ($OUs.Count -eq 0) {
   [System.Windows.Forms.MessageBox]::Show("No OUs found under $RootOU", "Error", "OK", "Error")
   exit
}
# Load Windows Forms
Add-Type -AssemblyName System.Windows.Forms
# Create Form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Select an Organizational Unit"
$Form.Size = New-Object System.Drawing.Size(800,300)
$Form.StartPosition = "CenterScreen"
# Create Label
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Choose an OU for this device:"
$Label.Location = New-Object System.Drawing.Point(20,20)
$Label.AutoSize = $true
$Form.Controls.Add($Label)
# Create ComboBox
$ComboBox = New-Object System.Windows.Forms.ComboBox
$ComboBox.Location = New-Object System.Drawing.Point(20,50)
$ComboBox.Size = New-Object System.Drawing.Size(700,100)
$ComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$ComboBox.Items.AddRange($OUs)
$Form.Controls.Add($ComboBox)
# Create OK Button
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Text = "OK"
$OKButton.Location = New-Object System.Drawing.Point(150,80)
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$Form.AcceptButton = $OKButton
$Form.Controls.Add($OKButton)
# Show Form
$Result = $Form.ShowDialog()
# Set selected OU variable if OK is pressed
if ($Result -eq [System.Windows.Forms.DialogResult]::OK -and $ComboBox.SelectedItem) {
   $SelectedOU = $ComboBox.SelectedItem
   [System.Windows.Forms.MessageBox]::Show("You selected: $SelectedOU", "Selection Confirmed", "OK", "Information")
} else {
   $SelectedOU = $null
   [System.Windows.Forms.MessageBox]::Show("No OU selected.", "Warning", "OK", "Warning")
}
# Output the selected OU
Write-Output "Selected OU: $SelectedOU"
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$tsenv.value("OSDDomainOUName") = "LDAP://$SelectedOU"