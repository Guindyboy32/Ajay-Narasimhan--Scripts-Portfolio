# Import user data from CSV file
$Users = Import-Csv -Path "C:\Users\YourUsername\Documents\NewUsers.csv"

# Create users and assign licenses
foreach ($User in $Users) {
    $UserPrincipalName = $User.UserPrincipalName
    $DisplayName = $User.DisplayName
    $Password = $User.Password
    $License = "yourdomain:ENTERPRISEPACK"

    # Create the new user
    New-MsolUser -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName -Password $Password

    # Assign a license to the new user
    Set-MsolUserLicense -UserPrincipalName $UserPrincipalName -AddLicenses $License
}
