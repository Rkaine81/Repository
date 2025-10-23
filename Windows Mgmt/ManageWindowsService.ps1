#Set Windows Service states. Start/Stop services and Set Start type.
#Example: Check-Service -SERVICE "AdobeARMservice" -STARTTYPE Automatic -ACTION Start
function Check-Service {

    param(
        [Parameter(Mandatory=$true)]
        [string]$SERVICE,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Disabled','Manual','Automatic', 'Automatic (Delayed Start)')]
        [string]$STARTTYPE,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Start','Stop')]
        [string]$ACTION
    
    )

        
    if ($ACTION -eq "Stop") {$STATUS = "Stopped"} 
    if ($ACTION -eq "Start") {$STATUS = "Running"} 

    write-output "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    write-output "The current Service state for $SERVICE is: $($(get-service $SERVICE).Status)."
    if ($(get-service $SERVICE).Status -ne $STATUS ) {write-output "Attempting to $ACTION the Service: $SERVICE."}



        if ((get-service $SERVICE).Status -ne $STATUS -and $ACTION -eq "Start") {Start-Service -Name $SERVICE}
        if ((get-service $SERVICE).Status -ne $STATUS -and $ACTION -eq "Stop") {Stop-Service -Name $SERVICE}

        if ((get-service $SERVICE).Status -eq $STATUS) {write-output "The Service State for $SERVICE is set to: $($(get-service $SERVICE).Status)."} else {write-output "Warning: The Service State for $SERVICE could not be changed." ; $ERROR = "1"}



    write-output "The current Service startup type for $SERVICE is: $($(get-service $SERVICE).StartType)."
    if ($(get-service $SERVICE).StartType -ne $STARTTYPE ) {write-output "Attempting to set the Service startup type to $STARTTYPE for: $SERVICE."}

        if ((get-service $SERVICE).StartType -ne $STARTTYPE) {Set-Service -Name $SERVICE -StartupType $STARTTYPE}
            start-sleep 3
        if ((get-service $SERVICE).StartType -eq $STARTTYPE) {write-output "The Startup Type for $SERVICE is set to $($(get-service $SERVICE).StartType)." } else {write-output "Warning: The Startup Type for $SERVICE could not be changed."}


    if ($ERROR -eq "1") {
        write-output "The current Service state for $SERVICE is still: $($(get-service $SERVICE).Status)."
        write-output "Attempting to $ACTION the Service again: $SERVICE."

            if ($ACTION -eq "Stop") {$STATUS = "Stopped"} 
            if ($ACTION -eq "Start") {$STATUS = "Running"} 

            if ((get-service $SERVICE).Status -ne $STATUS -and $ACTION -eq "Start") {Start-Service -Name $SERVICE}
            if ((get-service $SERVICE).Status -ne $STATUS -and $ACTION -eq "Stop") {Stop-Service -Name $SERVICE}

            if ((get-service $SERVICE).Status -eq $STATUS) {write-output "The Service State for $SERVICE is set to $($(get-service $SERVICE).Status)."} else {write-output "Error: The Service State for $SERVICE could not be changed."}
    }
}


Check-Service -SERVICE WerSvc -STARTTYPE Automatic -ACTION Start
