# Load Windows Forms
Add-Type -AssemblyName System.Windows.Forms
# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "File Search Tool"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
# Create a label for the file input
$labelFile = New-Object System.Windows.Forms.Label
$labelFile.Text = "Select a file:"
$labelFile.AutoSize = $true
$labelFile.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($labelFile)
# Create a textbox for the file input
$textBoxFile = New-Object System.Windows.Forms.TextBox
$textBoxFile.Size = New-Object System.Drawing.Size(300, 20)
$textBoxFile.Location = New-Object System.Drawing.Point(100, 18)
$form.Controls.Add($textBoxFile)
# Create a button for browsing files
$buttonBrowse = New-Object System.Windows.Forms.Button
$buttonBrowse.Text = "Browse"
$buttonBrowse.Location = New-Object System.Drawing.Point(410, 16)
$form.Controls.Add($buttonBrowse)
# Create a label for the search string input
$labelString = New-Object System.Windows.Forms.Label
$labelString.Text = "Enter search string:"
$labelString.AutoSize = $true
$labelString.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($labelString)
# Create a textbox for the search string input
$textBoxString = New-Object System.Windows.Forms.TextBox
$textBoxString.Size = New-Object System.Drawing.Size(300, 20)
$textBoxString.Location = New-Object System.Drawing.Point(130, 58)
$form.Controls.Add($textBoxString)
# Create a button to start the search
$buttonSearch = New-Object System.Windows.Forms.Button
$buttonSearch.Text = "Search"
$buttonSearch.Location = New-Object System.Drawing.Point(200, 100)
$form.Controls.Add($buttonSearch)
# Create a textbox to display the results
$textBoxResults = New-Object System.Windows.Forms.TextBox
$textBoxResults.Multiline = $true
$textBoxResults.ScrollBars = "Vertical"
$textBoxResults.Size = New-Object System.Drawing.Size(460, 200)
$textBoxResults.Location = New-Object System.Drawing.Point(10, 140)
$form.Controls.Add($textBoxResults)
# Function to open the file dialog and select a file
$buttonBrowse.Add_Click({
   $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
   $fileDialog.Filter = "All files (*.*)|*.*"
   if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
       $textBoxFile.Text = $fileDialog.FileName
   }
})
# Function to search the file for the specified string
$buttonSearch.Add_Click({
   $filePath = $textBoxFile.Text
   $searchString = $textBoxString.Text
   if (-not [string]::IsNullOrEmpty($filePath) -and (Test-Path $filePath) -and -not [string]::IsNullOrEmpty($searchString)) {
       $results = Get-Content $filePath | Select-String -Pattern $searchString
       $textBoxResults.Lines = $results.Line
   } else {
       [System.Windows.Forms.MessageBox]::Show("Please provide a valid file path and search string.")
   }
})
# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()