************************************************************************************************
Qualys Agent Local Health Check Tool Report : 
************************************************************************************************

Overall Health : Good

Services : 

	Name : qualysagent
	State : Running

Certificates : 

	Name : DigiCert Global Root CA
	Installed : true

Agent Communication Details : 

	Last CAPI : 2024-06-04 13:05:11.846
	CAPI Interval : 2700

Backend Connectivity : 

	Direct Connection : 
		URL : https://qagpublic.qg2.apps.qualys.com/status
		Connection Succeeded : true

Modules : 

	Name : Vulnerability
	Module Type : Scan based
	State : Ready for Scan
	Enabled : true
	Last Scan Time : 2024-06-04 13:10:21.897
	Scan Interval : 14400
	Next Scan Time : 2024-06-04 18:10:21
	VM Scan Deadline : 2024-06-06 18:10:21
	Module Health : Vulnerability Health Good

	Name : PolicyCompliance 
	Module Type : Scan based
	Enabled : false

	Name : SCA
	Module Type : Scan based
	State : Ready for Scan
	Enabled : true
	Last Scan Time : 2024-06-04 04:49:40.689
	Scan Interval : 129600
	Next Scan Time : 2024-06-05 17:49:40
	SCA Scan Deadline : 2024-06-07 17:49:40
	Module Health : SCA Health Good

	Name : Patch Management
	Module Type : Realtime
	Enabled : true
	Patch Connectivity : 
		Direct Connection : 
			URL : https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5/npp.8.5.Installer.x64.exe
			Connection Succeeded : true
	Module Health : Patch Management Health Good


Detailed Report Location : C:\WINDOWS\system32\HealthCheck\qualys_agent_health_check_6494352.json
Concise Text Report Location : C:\WINDOWS\system32\HealthCheck\qualys_agent_health_check_6494352.txt