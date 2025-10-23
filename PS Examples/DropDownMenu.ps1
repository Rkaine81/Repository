$snip = $env:SMS_ADMIN_UI_PATH.Length-5
$modpath = $env:SMS_ADMIN_UI_PATH.Substring(0,$snip)
Import-Module "$modpath\ConfigurationManager.psd1"
$SiteCode = Get-PSDrive -PSProvider CMSite
Set-Location "$($SiteCode.Name):\"

$CMDP=Get-CMDistributionPoint
$CMTS=Get-CMTaskSequence
$DISK = Get-WmiObject Win32_LogicalDisk

#Edit This item to change the DropDown Values
[array]$DropDownArray=$CMDP.NetworkOSPath
[array]$DropDownArray2=$CMTS.Name
[array]$DropDownArray3=$DISK.Name

#This Function Returns the Selected Value and Closes the Form

function Return-DropDown {

$script:Choice = $DropDown.SelectedItem.ToString()
$script:Choice = $DropDown2.SelectedItem.ToString()
$script:Choice = $DropDown3.SelectedItem.ToString()
 $Form.Close()
}

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$Form = New-Object System.Windows.Forms.Form

$Form.width = 400
$Form.height = 350
$Form.Text = ”Build Offline Task Sequence Media”

#Dropdown box1
$DropDown = new-object System.Windows.Forms.ComboBox
$DropDown.Location = new-object System.Drawing.Size(100 ,20)
$DropDown.Size = new-object System.Drawing.Size(200,30)

ForEach ($Item in $DropDownArray) {
 [void] $DropDown.Items.Add($Item)
}

$Form.Controls.Add($DropDown)

$DropDownLabel = new-object System.Windows.Forms.Label
$DropDownLabel.Location = new-object System.Drawing.Size(10,20) 
$DropDownLabel.size = new-object System.Drawing.Size(100,20) 
$DropDownLabel.Text = "Distribution Point"
$Form.Controls.Add($DropDownLabel)

#Dropdown box2
$DropDown2 = new-object System.Windows.Forms.ComboBox
$DropDown2.Location = new-object System.Drawing.Size(100,110)
$DropDown2.Size = new-object System.Drawing.Size(200,30)

ForEach ($Item in $DropDownArray2) {
 [void] $DropDown2.Items.Add($Item)
}

$Form.Controls.Add($DropDown2)

$DropDownLabel2 = new-object System.Windows.Forms.Label
$DropDownLabel2.Location = new-object System.Drawing.Size(10,110) 
$DropDownLabel2.size = new-object System.Drawing.Size(100,20) 
$DropDownLabel2.Text = "Task Sequence"
$Form.Controls.Add($DropDownLabel2)

#Dropdown box3
$DropDown3 = new-object System.Windows.Forms.ComboBox
$DropDown3.Location = new-object System.Drawing.Size(100,210)
$DropDown3.Size = new-object System.Drawing.Size(200,30)

ForEach ($Item in $DropDownArray3) {
 [void] $DropDown3.Items.Add($Item)
}

$Form.Controls.Add($DropDown3)

$DropDownLabel3 = new-object System.Windows.Forms.Label
$DropDownLabel3.Location = new-object System.Drawing.Size(10,210) 
$DropDownLabel3.size = new-object System.Drawing.Size(100,200) 
$DropDownLabel3.Text = "Drive Letter"
$Form.Controls.Add($DropDownLabel3)

$Button3 = new-object System.Windows.Forms.Button
$Button3.Location = new-object System.Drawing.Size(130,260)
$Button3.Size = new-object System.Drawing.Size(125,20)
$Button3.Text = "Create Offline Media"
$Button3.Add_Click({Return-DropDown})
$form.Controls.Add($Button3)

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()

$DP1 =(Get-CMDistributionPoint -SiteSystemServerName $DropDown.SelectedItem.ToString())
$TS1 =(Get-CMTaskSequence -Name $DropDown2.SelectedItem.ToString())
$DL1 =$DropDown3.SelectedItem.ToString()
Write-Output $DP1.NetworkOSPath
Write-Output $TS1.Name
Write-Output $DL1
Write-Output New-CMTaskSequenceMedia -DriveName $DL1\ -StandaloneMedia -MediaInputType Usb -TaskSequence $TS1 -TaskSequenceDistributionPoint $DP1 -MediaPath $DL1\ 