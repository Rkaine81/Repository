$inf = import-csv -Path "C:\temp2\WVDConfig.inf" -Header val

$infVal0 = $inf.val[0]
$infVal1 = $inf.val[1]
$infVal2 = ConvertTo-SecureString $infVal1 -AsPlainText -Force
#$infVal3 = New-Object System.Management.Automation.PSCredential ($infVal0, $infVal2)

New-Object System.Management.Automation.PSCredential ($infVal0, $infVal2) | Export-Clixml -Path "C:\temp\WVDConfig.xml"

#This is how you import the file
#$infVal3 = Import-Clixml -Path "C:\temp\WVDConfig.xml"
