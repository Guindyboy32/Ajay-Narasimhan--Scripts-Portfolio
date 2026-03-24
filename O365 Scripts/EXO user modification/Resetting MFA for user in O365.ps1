# Define user details
$UserPrincipalName = "user@yourdomain.com"

# Enable MFA for the user
Set-MsolUser -UserPrincipalName $UserPrincipalName -StrongAuthenticationRequirements @()
