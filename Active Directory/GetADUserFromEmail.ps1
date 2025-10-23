<#
"Skidmore", "Kristi", "Kristi.Skidmore@choa.org"
"Carpenter, Milanne, Milanne.Carpenter@choa.org"
"Hill, Aubrey, Aubrey.Hill@choa.org"
"Ray, Teresa, Teresa.Ray@Choa.org"
"Dickson, Paula, paula.dickson@choa.org"
"Kadom, Nadja , Nadja.Kadom@choa.org"
"Glackin, Annie, Grace.Glackin@choa.org"
"Haas, Sarah, Sarah.Haas@choa.org"
"Cole, Laurie, Laurie.Cole@choa.org"
#>

# Define the headers
$headers = @('Last', 'First', 'Email')

# Create a list of data entries
$data = @(
    @("Skidmore", "Kristi", "Kristi.Skidmore@choa.org"),
    @("Carpenter", "Milanne", "Milanne.Carpenter@choa.org"),
    @("Hill", "Aubrey", "Aubrey.Hill@choa.org"),
    @("Ray", "Teresa", "Teresa.Ray@Choa.org"),
    @("Dickson", "Paula", "paula.dickson@choa.org"),
    @("Kadom", "Nadja", "Nadja.Kadom@choa.org"),
    @("Glackin", "Annie", "Grace.Glackin@choa.org"),
    @("Haas", "Sarah", "Sarah.Haas@choa.org"),
    @("Cole", "Laurie", "Laurie.Cole@choa.org")
)

# Convert the data to a list of objects
$userObj = $data | ForEach-Object {
    [PSCustomObject]@{
        Last  = $_[0]
        First = $_[1]
        Email = $_[2]
    }
}

# Display the results
#$userObj
<#
foreach ($userRecord in $userObj) {
    Get-ADUser -Filter "mail -eq '$($userRecord.Email)'" -Properties mail
}
#>

# Iterate over each user and attempt to find them in AD
foreach ($userRecord in $userObj) {
    try {
        # Attempt to find the user by their email address
        $user = Get-ADUser -Filter "mail -eq '$($userRecord.Email)'" -Properties mail, Description, Title, Manager, Department

        if ($user) {
            # Retrieve the manager's name if the Manager attribute is set
            $managerName = if ($user.Manager) {
                $manager = Get-ADUser -Identity $user.Manager -Properties DisplayName
                $manager.DisplayName
            } else {
                "N/A"
            }

            # Display the user's details including additional properties
            $user | Select-Object SamAccountName, Name, mail, Description, Title, @{Name="Manager";Expression={$managerName}}, Department
        } else {
            Write-Host "No AD user found for email: $($userRecord.Email)"
        }
    } catch {
        Write-Host "An error occurred while processing email: $($userRecord.Email)"
        Write-Host $_.Exception.Message
    }
}

# Create a collection to store results
$results = @()

# Iterate over each user and attempt to find them in AD
foreach ($userRecord in $userObj) {
    try {
        # Attempt to find the user by their email address
        $user = Get-ADUser -Filter "mail -eq '$($userRecord.Email)'" -Properties mail, Description, Title, Manager, Department

        if ($user) {
            # Retrieve the manager's name if the Manager attribute is set
            $managerName = if ($user.Manager) {
                $manager = Get-ADUser -Identity $user.Manager -Properties DisplayName
                $manager.DisplayName
            } else {
                "N/A"
            }

            # Add the user's details to the results collection
            $results += [PSCustomObject]@{
                SamAccountName = $user.SamAccountName
                Name           = $user.Name
                Email          = $user.mail
                Description    = $user.Description
                Title          = $user.Title
                Manager        = $managerName
                Department     = $user.Department
            }
        } else {
            Write-Host "No AD user found for email: $($userRecord.Email)"
        }
    } catch {
        Write-Host "An error occurred while processing email: $($userRecord.Email)"
        Write-Host $_.Exception.Message
    }
}

# Display the results in a grid view
$results | Out-GridView