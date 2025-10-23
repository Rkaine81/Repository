 # UPDATE CURRENT CHANNEL USERS TO MONTHLY CHANNEL
    
    
 # ODT
 $ODTExecution = "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe"
 $Arguments = " /changesetting Channel=MonthlyEnterprise"
 Start-Process $ODTExecution -ArgumentList $Arguments -Verb Runas -Wait
  
 Start-Sleep -Seconds 30 
    
 # Client Update
 $Arguments2 = " /update user updatepromptuser=false forceappshutdown=false displaylevel=true"
 Start-Process $ODTExecution -ArgumentList $Arguments2 -Verb Runas -Wait