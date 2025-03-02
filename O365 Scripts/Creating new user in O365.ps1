# Define user details
$UserPrincipalName = "newuser@yourdomain.com"
$DisplayName = "New User"
$Password = "P@ssw0rd"

# Create the new user
New-MsolUser -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName -Password $Password

# Assign a license to the new user
$License = "yourdomain:ENTERPRISEPACK"
Set-MsolUserLicense -UserPrincipalName $UserPrincipalName -AddLicenses $License
