#SCCM_OSD_Configuration
#Created By: Adam Eaddy / Bryan Dam
#Created On:5/26/16
#
#This program prompts the user for configuration options including the primary user, hardware type, and
#the desired core set of applications.  It uses this information to create the machine name and queries
#active directory for the next available numer to make the name unique.  It then sets the appropriate
#task sequence variables and exits.

#Load the form assembly
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

#If the settings file exists then use it.
$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$settingsPath="$ScriptPath\settings.xml"
If (Test-Path $settingsPath -PathType Leaf){    
    [xml]$global:settings=Get-Content $settingsPath
}

$global:webServiceURLTemplate="http://%MP%/mjr_cm_websvc/mjr_cm_websvc.asmx?WSDL"
#Get the task sequence variables.
$global:TSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
$global:mjr_environment=$global:TSEnv.Value("mjr_environment")
$global:mjr_environment='DUS'#
$global:mjr_os_version=$global:TSEnv.Value("mjr_os_version")
$global:mjr_os_version='7'#
$global:mjr_machine_name_prefix=$global:TSEnv.Value("mjr_machine_name_prefix")
$global:mjr_machine_name_prefix='OF'#
$global:task_seqence_mp=$global:TSEnv.Value("_SMSTSMP")
$global:task_seqence_mp="http://w0982dappv0603.dus.meijer.com"#
$global:mjrWebService=$null


#If we don't have task sequence variables exit with error.
if ((-not $global:mjr_environment) -or (-not $global:mjr_os_version) -or (-not $global:mjr_machine_name_prefix) -or (-not $global:task_seqence_mp)) { 
    Write-Host "Task sequence variables missing."
    exit -2 
}

#This function takes a FQDN for a management point and returns a randomzied list of available managemement points.
Function Get-MPList
{
    Param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$mpFQDN
    )

    Try {
        $ErrorActionPreference = "Stop"; #Make all errors terminating

        #Get the list of management points from the passed in management point.
        $mpURL="$mpFQDN/sms_mp/.sms_aut?mplist"
        [xml]$mpList = (New-Object System.Net.WebClient).DownloadString($mpURL)
    
        #Return a randomized collection of the MP list objects.
        return ($mpList.MPList.MP | Sort-Object {Get-Random})
    }
    Catch
    {
        #Write-Host "Get-MPList caught a generic Exception"
        Throw $_.Exception
    }
    Finally{
        $ErrorActionPreference = "Continue"; #Reset the error action pref to default
    }
}


#This function configures the Computer Lookup web service.
Function Configure-WebService
{
    #Get the list of management points.
    Try {
        $mpList=Get-MPList($global:task_seqence_mp)
    }
    Catch {
        Write-Error "Failed to get Management Point list: $_"
    }

    #Set up the service object by looking for the web service on each MP.
    If ($mpList) {
        ForEach ($mpFQDN in $mpList.FQDN){
            Try{
                $ErrorActionPreference="Stop"; #Make all errors terminating
                $global:mjrWebService=New-WebServiceProxy �Uri $webServiceURLTemplate.Replace("%MP%",$mpFQDN)
            }
            Catch
            {
                #Do nothing, go on to the next management point.
                #Write-Host "Failed:$mpFQDN"
            }
            Finally{
                $ErrorActionPreference = "Continue"; #Reset the error action pref to default
            }
        }
    }
}

Function Load-Form 
{    
    $Form.Controls.Add($GBEmplID)
    $Form.Controls.Add($GBType)
    $Form.Controls.Add($GBMachineName)
    $Form.Controls.Add($GBCoreApps)
    $Form.Controls.Add($ButtonOK)
    $Form.Add_Shown({$Form.Activate()})

    #Configure the web service.
    Configure-WebService

    #Set the Username if it exists.
    if ($global:TSEnv.Value("SMSTSUdaUsers")){
        $TBEmplID.Text = ($global:TSEnv.Value("SMSTSUdaUsers") -replace "$global:mjr_environment\\")
    }

    #Set the computer if it exists.
    if ($global:TSEnv.Value("OSDComputerName")){
        $TBMachineName.Text = ($global:TSEnv.Value("OSDComputerName") -replace "$global:mjr_environment\\")
    }

    #Load the list of cores.
        if ($global:settings){
        foreach ($core in $global:settings.Settings.Cores.Core) {
            $CBCoreApps.Items.Add($core.Name) | Out-Null
        }
        $CBCoreApps.SelectedIndex = 0
    }

    [void] $Form.ShowDialog()
}

Function SCCM_OSD_Configuration{
  
  #Validate machine name has something.
    if ($TBMachineName.Text.Length -gt 0) { 
        
        #Set the task sequence varibles and close the form.
        $global:TSEnv.Value("OSDComputerName")="$($TBMachineName.Text)"        
        $global:TSEnv.Value("SMSTSUdaUsers")="$global:mjr_environment\$($TBEmplID.Text)"

        #Set the core app variable if the settings were loaded.
        if($global:settings){
            $taskVariable=$global:settings.Settings.Cores.tsvariable
            $global:TSEnv.Value($taskVariable)=$global:settings.Settings.Cores.Core[$CBCoreApps.SelectedIndex].Value
        }

        $Form.Close() 
        }
    else {
        [System.Windows.Forms.MessageBox]::Show("You must enter a machine name.")
        ValidateData
    }
}
 
Function ValidateData 
{
   
    $ErrorProvider.Clear()

    #Validate employee id length and content.
    if ($TBEmplID.Text.Length -eq 0) 
    {
        $ErrorProvider.SetError($GBEmplID, "Please enter an employee ID.")
    }

    elseif ($TBEmplID.Text.Length -lt 6) 
    {
        $ErrorProvider.SetError($GBEmplID, "Employee ID cannot be less than 6 characters.")
    }

    elseif ($TBEmplID.Text.Length -gt 7) 
    {
        $ErrorProvider.SetError($GBEmplID, "Employee ID cannot be more than 7 characters.")
    }
    elseif ($TBEmplID.Text -match "^[-_]|[^a-zA-Z0-9-_]")
    {
        $ErrorProvider.SetError($GBEmplID, "Employee ID invalid, please correct the user name.")
    }

    #Search active directory for the user.
    Try{
        $ErrorActionPreference="Stop"; #Make all errors terminating
        $userExists=$global:mjrWebService.CheckUserName($TBEmplID.Text)

        #If the user doesn't exist set the error provider.
        if ($userExists -ne "True")
        {
            $ErrorProvider.SetError($GBEmplID, "Employee ID invalid, user does not exist in active directory.")
        }
    }
    Catch
    {
        #Do nothing, ignore the error.
    }
    Finally
    {
        $ErrorActionPreference = "Continue"
    }
  

   if ((-Not $ErrorProvider.GetError($GBEmplID)) -and ($global:machine_type)) { 

        #Partial machine name.
        $machineName = "$global:mjr_machine_name_prefix$($TBEmplID.Text)-$global:mjr_os_version$global:machine_type"
        
        #Search active directory for incremented computer name.  If there's an error just add 01.
        Try{
            $ErrorActionPreference="Stop"; #Make all errors terminating
            $machineName=$global:mjrWebService.GetComputerName($machineName)
        }
        Catch
        {
            $machineName="${machineName}01"
        }
        Finally
        {
            $ErrorActionPreference = "Continue"
        }


        #Set the machine name text box.   
        $TBMachineName.Text = $machineName
        $ButtonOK.Enabled = $True
    }
   else { 
    $TBMachineName.Text = ""
    $ButtonOK.Enabled = $False 
   }

}

 
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
 
$Global:ErrorProvider = New-Object System.Windows.Forms.ErrorProvider
 
$Form = New-Object System.Windows.Forms.Form    
#$Form.Size = New-Object System.Drawing.Size(285,440)  
$Form.MinimumSize = New-Object System.Drawing.Size(285,140)
$Form.MaximumSize = New-Object System.Drawing.Size(285,600)
$Form.AutoSize = $true
$Form.AutoSizeMode = AutoSizeMode.GrowAndShrink
$Form.StartPosition = "CenterScreen"
$Form.SizeGripStyle = "Hide"
$Form.Text = "Enter Employee ID ($global:mjr_environment)"
$Form.ControlBox = $false
$Form.TopMost = $true
 
$GBEmplID = New-Object System.Windows.Forms.GroupBox
$GBEmplID.Location = New-Object System.Drawing.Size(20,20)
$GBEmplID.Size = New-Object System.Drawing.Size(225,40)
$GBEmplID.Text = "Employee ID:"

$TBEmplID = New-Object System.Windows.Forms.TextBox
$TBEmplID.Location = New-Object System.Drawing.Size(5,15)
$TBEmplID.Size = New-Object System.Drawing.Size(215,50)
$TBEmplID.MaxLength = 7
$TBEmplID.TabIndex = "1"
$TBEmplID.Add_KeyUp({ValidateData})
$GBEmplID.Controls.Add($TBEmplID) 

$RBType_Desktop = New-Object System.Windows.Forms.RadioButton
$RBType_Desktop.Location = New-Object System.Drawing.Point(5,15)
$RBType_Desktop.Size = New-Object System.Drawing.Size(80,20) 
$RBType_Desktop.Add_CheckedChanged({if($RBType_Desktop.Checked){$global:machine_type="D";ValidateData}})
$RBType_Desktop.Text = "Desktop"
$RBType_Desktop.TabIndex = "2"
$RBType_Desktop.TabStop=$true 

$RBType_Laptop = New-Object System.Windows.Forms.RadioButton
$RBType_Laptop.Location = New-Object System.Drawing.Point(5,($RBType_Desktop.Location.Y + $RBType_Desktop.Size.Height))
$RBType_Laptop.Size = New-Object System.Drawing.Size(80,20)
$RBType_Laptop.Add_CheckedChanged({if($RBType_Laptop.Checked){$global:machine_type="L";ValidateData}})
$RBType_Laptop.Text = "Laptop" 

$RBType_Tablet = New-Object System.Windows.Forms.RadioButton
$RBType_Tablet.Location = New-Object System.Drawing.Point(5,($RBType_Laptop.Location.Y + $RBType_Laptop.Size.Height))
$RBType_Tablet.size = New-Object System.Drawing.Size(80,20) 
$RBType_Tablet.Add_CheckedChanged({if($RBType_Tablet.Checked){$global:machine_type="T";ValidateData}})
$RBType_Tablet.Text = "Tablet" 

$RBType_Virtual = New-Object System.Windows.Forms.RadioButton
$RBType_Virtual.Location = New-Object System.Drawing.Point(5,($RBType_Tablet.Location.Y + $RBType_Tablet.Size.Height))
$RBType_Virtual.size = New-Object System.Drawing.Size(80,20) 
$RBType_Virtual.Add_CheckedChanged({if($RBType_Virtual.Checked){$global:machine_type="V";ValidateData}})
$RBType_Virtual.Text = "Virtual"
 
$GBType = New-Object System.Windows.Forms.GroupBox
$GBType.Location = New-Object System.Drawing.Size(20,($GBEmplID.Location.Y + $GBEmplID.Size.Height + 10))
$GBType.Size = New-Object System.Drawing.Size(225,100)
$GBType.Text = "Device Type:"
$GBType.Controls.Add($RBType_Desktop)
$GBType.Controls.Add($RBType_Laptop)
$GBType.Controls.Add($RBType_Tablet)
$GBType.Controls.Add($RBType_Virtual)
 
$GBMachineName = New-Object System.Windows.Forms.GroupBox
$GBMachineName.Location = New-Object System.Drawing.Size(20,($GBType.Location.Y + $GBType.Size.Height + 10))
$GBMachineName.Size = New-Object System.Drawing.Size(225,40)
$GBMachineName.Text = "Machine Name:"

$TBMachineName = New-Object System.Windows.Forms.TextBox
$TBMachineName.Location = New-Object System.Drawing.Size(5,15)
$TBMachineName.Size = New-Object System.Drawing.Size(215,50)
$TBMachineName.TabIndex = "3"
$GBMachineName.Controls.Add($TBMachineName) 

$GBCoreApps = New-Object System.Windows.Forms.GroupBox
$GBCoreApps.Location = New-Object System.Drawing.Size(20,($GBMachineName.Location.Y + $GBMachineName.Size.Height + 10))
$GBCoreApps.Size = New-Object System.Drawing.Size(225,40)
$GBCoreApps.Text = "Core Applications:"

$CBCoreApps = New-Object System.Windows.Forms.ComboBox
$CBCoreApps.Location = New-Object System.Drawing.Size(5,15)
$CBCoreApps.Size = New-Object System.Drawing.Size(215,50)
$CBCoreApps.TabIndex = "3"
$GBCoreApps.Controls.Add($CBCoreApps)
 
$ButtonOK = New-Object System.Windows.Forms.Button
$ButtonOK.Location = New-Object System.Drawing.Size(195,($GBCoreApps.Location.Y + $GBCoreApps.Size.Height + 10))
$ButtonOK.Size = New-Object System.Drawing.Size(50,20)
$ButtonOK.Text = "OK"
$ButtonOK.TabIndex = "4"
$ButtonOK.Enabled = $False
$ButtonOK.Add_Click({SCCM_OSD_Configuration})

$Form.KeyPreview = $True
$Form.Add_KeyDown({if ($_.KeyCode -eq "Enter"){SCCM_OSD_Configuration}})

Load-Form