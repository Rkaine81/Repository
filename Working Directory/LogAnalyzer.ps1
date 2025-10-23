# Load the required assembly for the GUI

Add-Type -AssemblyName PresentationFramework

# Function to create the GUI

function Show-ErrorLogGUI {

    param (

        [string]$errorLog

    )

    # Create a window

    $window = New-Object System.Windows.Window

    $window.Title = "Event Log Errors"

    $window.Width = 800

    $window.Height = 600

    # Create a text box to display the errors

    $textBox = New-Object System.Windows.Controls.TextBox

    $textBox.VerticalScrollBarVisibility = "Auto"

    $textBox.HorizontalScrollBarVisibility = "Auto"

    $textBox.TextWrapping = "Wrap"

    $textBox.IsReadOnly = $true

    $textBox.Text = $errorLog

    # Add the text box to the window

    $window.Content = $textBox

    # Show the window

    $window.ShowDialog()

}

# Function to get errors from a specific log

function Get-LogErrors {

    param (

        [string]$logName

    )

    # Get the error events from the specified log

    $events = Get-WinEvent -LogName $logName -ErrorAction SilentlyContinue | Where-Object { $_.LevelDisplayName -eq "Error" }

    $logErrors = ""

    foreach ($event in $events) {

        $logErrors += "Time: $($event.TimeCreated)`n"

        $logErrors += "Source: $($event.ProviderName)`n"

        $logErrors += "Event ID: $($event.Id)`n"

        $logErrors += "Message: $($event.Message)`n"

        $logErrors += "`n------------------------`n"

    }

    return $logErrors

}

# Get errors from Application, System, and Security logs

$appErrors = Get-LogErrors -logName "Application"

$sysErrors = Get-LogErrors -logName "System"

$secErrors = Get-LogErrors -logName "Security"

# Combine all errors

$allErrors = "Application Log Errors:`n`n$appErrors"

$allErrors += "`nSystem Log Errors:`n`n$sysErrors"

$allErrors += "`nSecurity Log Errors:`n`n$secErrors"

# Show the errors in the GUI

Show-ErrorLogGUI -errorLog $allErrors