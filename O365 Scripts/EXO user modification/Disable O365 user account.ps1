# Define user details
$UserPrincipalName = "user@yourdomain.com"

# Disable the user account
Set-MsolUser -UserPrincipalName $UserPrincipalName -BlockCredential $true
