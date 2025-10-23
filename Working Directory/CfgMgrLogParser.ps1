Add-Type -AssemblyName PresentationFramework
function Show-LogParserGUI {
   [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
       xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
       Title="Configuration Manager Log Parser"
       Height="450"
       Width="600">
<Grid Margin="10">
<Grid.RowDefinitions>
<RowDefinition Height="Auto"/>
<RowDefinition Height="Auto"/>
<RowDefinition Height="*"/>
<RowDefinition Height="Auto"/>
</Grid.RowDefinitions>
<Grid.ColumnDefinitions>
<ColumnDefinition Width="*"/>
<ColumnDefinition Width="Auto"/>
</Grid.ColumnDefinitions>
<Label Grid.Row="0" Grid.Column="0" Margin="5">Search String:</Label>
<TextBox x:Name="SearchTextBox" Grid.Row="0" Grid.Column="1" Margin="5" Width="400"/>
<Button x:Name="SearchButton" Grid.Row="0" Grid.Column="2" Margin="5" Width="75" Content="Search"/>
<TextBox x:Name="ResultsTextBox" Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="3" Margin="5" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" AcceptsReturn="True" IsReadOnly="True"/>
<Button x:Name="SaveButton" Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="3" Margin="5" Width="75" Content="Save Results" HorizontalAlignment="Left"/>
</Grid>
</Window>
"@
   $reader = (New-Object System.Xml.XmlNodeReader $xaml)
   $form = [Windows.Markup.XamlReader]::Load($reader)
   $SearchButton = $form.FindName('SearchButton')
   $SearchTextBox = $form.FindName('SearchTextBox')
   $ResultsTextBox = $form.FindName('ResultsTextBox')
   $SaveButton = $form.FindName('SaveButton')
   $SearchButton.Add_Click({
       $searchString = $SearchTextBox.Text
       $logDirectory = "C:\Windows\CCM\Logs"
       if ([string]::IsNullOrEmpty($searchString)) {
           [System.Windows.MessageBox]::Show("Please provide a search string.", "Input Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
           return
       }
       if (-not (Test-Path -Path $logDirectory)) {
           [System.Windows.MessageBox]::Show("The log directory '$logDirectory' does not exist.", "Directory Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
           return
       }
       $ResultsTextBox.Clear()
       $logFiles = Get-ChildItem -Path $logDirectory -Filter *.log
       foreach ($file in $logFiles) {
           $lines = Get-Content -Path $file.FullName
           foreach ($line in $lines) {
               if ($line -match [regex]::Escape($searchString)) {
                   $highlightedLine = $line -replace ([regex]::Escape($searchString)), "`e[1;31m$searchString`e[0m"
                   $ResultsTextBox.AppendText("$($file.Name): $highlightedLine`n")
               }
           }
       }
       if ($ResultsTextBox.Text.Length -eq 0) {
           $ResultsTextBox.AppendText("No lines containing '$searchString' found.`n")
       }
   })
   $SaveButton.Add_Click({
       $saveFileDialog = New-Object Microsoft.Win32.SaveFileDialog
       $saveFileDialog.Filter = "Log files (*.log)|*.log|All files (*.*)|*.*"
       if ($saveFileDialog.ShowDialog() -eq $true) {
           $savePath = $saveFileDialog.FileName
           $ResultsTextBox.Text | Out-File -FilePath $savePath -Encoding UTF8
           [System.Windows.MessageBox]::Show("Results saved to '$savePath'.", "Save Results", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
       }
   })
   $form.ShowDialog() | Out-Null
}
Show-LogParserGUI