#This script contains 
#The first example shows how to import from a CSV file and outputing to a JSON file. 
#The second example will import an Excel xlsx file and outputs to a JSON file without the need to install Excel.  You do have to install the PSExcel module and import the module.


#Import from CSV
import-csv -Path "D:\Users\206676599\OneDrive - NBCUniversal\Temp\WVDApps.csv" | ConvertTo-Json | out-file -FilePath "D:\Users\206676599\OneDrive - NBCUniversal\Temp\WVDApps.json" -Append -NoClobber -Force



#Import from XLS
Install-Module PSExcel #Must be run as administrator and only 1 time per device to install the required module.
Import-Module psexcel
Import-XLSX -Path "D:\Users\206676599\OneDrive - NBCUniversal\Temp\WVDApps.xlsx" | ConvertTo-Json| out-file -FilePath "D:\Users\206676599\OneDrive - NBCUniversal\Temp\WVDApps.json"