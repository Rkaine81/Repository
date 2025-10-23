Function Get-AppliedUserGPOs {
    # Run gpresult and capture the output
    $output = & gpresult /v /scope:user

    # Convert the output to an array of lines
    $outputLines = $output -split "`r?`n"

    # Initialize a flag and an array to store applied GPOs
    $appliedGPOsSection = $false
    $gpoList = @()

    # Iterate through each line of the output
    foreach ($line in $outputLines) {
        # Check for the start of the "Applied Group Policy Objects" section
        if ($line -match "Applied Group Policy Objects") {
            $appliedGPOsSection = $true
            continue
        }

        # If in the "Applied Group Policy Objects" section, capture GPO names
        if ($appliedGPOsSection) {
            # If a line is empty or indented (indicating a GPO), add it to the list
            $trimmedLine = $line.Trim()
            if ($trimmedLine -eq "") {
                break
            }
            if ($line -match "^\s{8}") { # Capture lines that are indented (indicating a GPO)
                $gpoList += $trimmedLine
            }
        }
    }

    return $gpoList
}

Get-AppliedUserGPOs