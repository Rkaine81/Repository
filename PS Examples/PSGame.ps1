$global:timeline = @{
   "past" = 100
   "present" = 100
   "future" = 100
}
$global:inventory = @{}
function Show-Status {
   Write-Host "`nTimeline Stability:"
   Write-Host "Past: $($global:timeline.past)% | Present: $($global:timeline.present)% | Future: $($global:timeline.future)%"
   Write-Host "Inventory: $($global:inventory.Keys -join ', ')"
}
function Get-PlayerChoice {
   param (
       [string[]]$Options
   )
   $valid = $false
   while (-not $valid) {
       for ($i = 0; $i -lt $Options.Length; $i++) {
           Write-Host "[$($i + 1)] $($Options[$i])"
       }
       $choice = Read-Host "Enter your choice"
       if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $Options.Length) {
           $valid = $true
       }
       else {
           Write-Host "Invalid choice. Please try again."
       }
   }
   return [int]$choice - 1
}
function Update-Timeline {
   param (
       [string]$Era,
       [int]$Change
   )
   $global:timeline[$Era] += $Change
   if ($global:timeline[$Era] -lt 0) { $global:timeline[$Era] = 0 }
   if ($global:timeline[$Era] -gt 100) { $global:timeline[$Era] = 100 }
}
function Add-InventoryItem {
   param (
       [string]$Item
   )
   if (-not $global:inventory.ContainsKey($Item)) {
       $global:inventory[$Item] = 1
   }
   else {
       $global:inventory[$Item]++
   }
}
function Start-Game {
   Write-Host "Welcome to Quantum Shift: A Time-Bending Adventure!"
   Write-Host "You are a time traveler tasked with maintaining the stability of the timeline."
   Write-Host "Your actions in one era will affect others. Balance is key to prevent temporal collapse."
   $gameOver = $false
   while (-not $gameOver) {
       Show-Status
       $era = @("Past", "Present", "Future")[(Get-Random -Minimum 0 -Maximum 3)]
       Write-Host "`nA temporal anomaly has been detected in the $era!"
       $options = @(
           "Investigate the anomaly",
           "Stabilize the timeline",
           "Use a time artifact"
       )
       $choice = Get-PlayerChoice -Options $options
       switch ($choice) {
           0 { Investigate-Anomaly $era }
           1 { Stabilize-Timeline $era }
           2 { Use-TimeArtifact }
       }
       $gameOver = Check-GameOver
   }
}
function Investigate-Anomaly {
   param ([string]$Era)
   Write-Host "You investigate the anomaly in the $Era..."
   $puzzle = Get-Random -Minimum 1 -Maximum 4
   switch ($puzzle) {
       1 { Solve-RiddlePuzzle $Era }
       2 { Solve-SequencePuzzle $Era }
       3 { Solve-WordPuzzle $Era }
   }
}
function Solve-RiddlePuzzle {
   param ([string]$Era)
   $riddles = @(
       @{Q="I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I?"; A="echo"},
       @{Q="The more you take, the more you leave behind. What am I?"; A="footsteps"},
       @{Q="What has keys, but no locks; space, but no room; you can enter, but not go in?"; A="keyboard"}
   )
   $riddle = $riddles | Get-Random
   Write-Host "Solve this riddle to stabilize the anomaly:"
   Write-Host $riddle.Q
   $answer = Read-Host "Your answer"
   if ($answer.ToLower() -eq $riddle.A) {
       Write-Host "Correct! The anomaly is resolved."
       Update-Timeline -Era $Era -Change 10
       Add-InventoryItem "Temporal Token"
   }
   else {
       Write-Host "Incorrect. The anomaly grows stronger."
       Update-Timeline -Era $Era -Change -10
   }
}
function Solve-SequencePuzzle {
   param ([string]$Era)
   $sequences = @(
       @{Seq=@(2,4,6,8); Next=10},
       @{Seq=@(1,1,2,3,5); Next=8},
       @{Seq=@(3,6,9,12); Next=15}
   )
   $sequence = $sequences | Get-Random
   Write-Host "Complete the sequence to stabilize the anomaly:"
   Write-Host ($sequence.Seq -join ", ") + ", ?"
   $answer = Read-Host "Your answer"
   if ([int]$answer -eq $sequence.Next) {
       Write-Host "Correct! The anomaly is resolved."
       Update-Timeline -Era $Era -Change 10
       Add-InventoryItem "Quantum Chip"
   }
   else {
       Write-Host "Incorrect. The anomaly grows stronger."
       Update-Timeline -Era $Era -Change -10
   }
}
function Solve-WordPuzzle {
   param ([string]$Era)
   $puzzles = @(
       @{Word="TIMETR_VEL"; Answer="A"},
       @{Word="QU_NTUM"; Answer="A"},
       @{Word="PAR_DOX"; Answer="A"}
   )
   $puzzle = $puzzles | Get-Random
   Write-Host "Fill in the missing letter to stabilize the anomaly:"
   Write-Host $puzzle.Word
   $answer = Read-Host "Your answer"
   if ($answer.ToUpper() -eq $puzzle.Answer) {
       Write-Host "Correct! The anomaly is resolved."
       Update-Timeline -Era $Era -Change 10
       Add-InventoryItem "Chrono Crystal"
   }
   else {
       Write-Host "Incorrect. The anomaly grows stronger."
       Update-Timeline -Era $Era -Change -10
   }
}
function Stabilize-Timeline {
   param ([string]$Era)
   Write-Host "You attempt to stabilize the $Era timeline..."
   $stabilizeAmount = Get-Random -Minimum 5 -Maximum 16
   Update-Timeline -Era $Era -Change $stabilizeAmount
   Write-Host "You've increased the $Era timeline stability by $stabilizeAmount%"
}
function Use-TimeArtifact {
   if ($global:inventory.Count -eq 0) {
       Write-Host "You don't have any time artifacts to use!"
       return
   }
   Write-Host "Choose an artifact to use:"
   $artifacts = $global:inventory.Keys
   $choice = Get-PlayerChoice -Options $artifacts
   $artifact = $artifacts[$choice]
   $global:inventory[$artifact]--
   if ($global:inventory[$artifact] -eq 0) {
       $global:inventory.Remove($artifact)
   }
   switch ($artifact) {
       "Temporal Token" {
           $era = @("Past", "Present", "Future") | Get-Random
           Update-Timeline -Era $era -Change 15
           Write-Host "The Temporal Token stabilizes the $era, increasing its stability by 15%"
       }
       "Quantum Chip" {1
           foreach ($era in $global:timeline.Keys) {
               Update-Timeline -Era $era -Change 5
           }
           Write-Host "The Quantum Chip resonates through time, increasing all era stabilities by 5%"
       }
       "Chrono Crystal" {
           $lowEra = $global:timeline.GetEnumerator() | Sort-Object Value | Select-Object -First 1 -ExpandProperty Key
           Update-Timeline -Era $lowEra -Change 20
           Write-Host "The Chrono Crystal focuses on the weakest point in time, increasing $lowEra stability by 20%"
       }
   }
}
function Check-GameOver {
   if (($global:timeline.Values | Measure-Object -Minimum).Minimum -le 0) {
       Write-Host "`nA timeline has collapsed! The fabric of reality unravels..."
       Write-Host "Game Over"
       return $true
   }
   elseif (($global:timeline.Values | Measure-Object -Minimum).Minimum -ge 100) {
       Write-Host "`nAll timelines are fully stabilized! You've saved the continuum!"
       Write-Host "Congratulations, you've won!"
       return $true
   }
   return $false
}
Start-Game