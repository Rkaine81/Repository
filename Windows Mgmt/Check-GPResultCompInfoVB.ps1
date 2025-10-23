function Get-AppliedCompGPOs {
    # Run gpresult command and store the output
    $gpResultOutput = gpresult /v /r

    # Initialize an array to store applied GPO names
    $appliedGPOs = @()

    # Define a switch to process the output line by line
    $inGPOSection = $false

    # Iterate over each line of the output
    foreach ($line in $gpResultOutput) {
        # Check if the line indicates the start of the Applied GPOs section
        if ($line -match "Applied Group Policy Objects") {
            $inGPOSection = $true
            continue
        }

        # Check if the line indicates the end of the Applied GPOs section
        if ($inGPOSection -and ($line -match "The following GPOs were not applied")) {
            break
        }

        # If in the GPO section, extract GPO names
        if ($inGPOSection) {
            # Trim the line and check if it's a valid GPO name
            $trimmedLine = $line.Trim()
            if ($trimmedLine -ne "") {
                $appliedGPOs += $trimmedLine
            }
        }
    }

    # Return the list of applied GPOs
    return $appliedGPOs
}

# Example of using the function
$gpos = Get-AppliedGPOs
$gpos