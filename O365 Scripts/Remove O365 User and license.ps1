# Define user details
$UserPrincipalName = "user@yourdomain.com"

# Remove the user
Remove-MsolUser -UserPrincipalName $UserPrincipalName -Force

# Remove the user's license
Set-MsolUserLicense -UserPrincipalName $UserPrincipalName -RemoveLicenses "yourdomain:ENTERPRISEPACK"
