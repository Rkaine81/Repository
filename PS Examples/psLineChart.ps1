# Load the Chart Controls assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization
# Create a new chart object
$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
# Set the chart title
$chart.Titles.Add("Line Chart Example")
# Add data to the chart
$data = @{
   "January" = 10
   "February" = 20
   "March" = 30
   "April" = 25
   "May" = 35
}
# Hash table to map month names to numerical values
$monthMap = @{
   "January" = 1
   "February" = 2
   "March" = 3
   "April" = 4
   "May" = 5
}
foreach ($key in $data.Keys) {
   $series = New-Object System.Windows.Forms.DataVisualization.Charting.Series
   $series.Name = $key
   $month = $monthMap[$key]
   $date = Get-Date -Year 2022 -Month $month -Day 1
   $point = New-Object System.Windows.Forms.DataVisualization.Charting.DataPoint
   $point.AxisLabel = $key
   $point.XValue = $month
   $point.YValues = $data[$key]
   $series.Points.Add($point)
   $chart.Series.Add($series)
}
# Display the chart
$chartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$chart.ChartAreas.Add($chartArea)
$form = New-Object Windows.Forms.Form
$form.Text = "Line Chart Example"
$form.Width = 600
$form.Height = 400
$form.Controls.Add($chart)
$form.ShowDialog()