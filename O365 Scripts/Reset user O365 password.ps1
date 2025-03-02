# Define user details
$UserPrincipalName = "user@yourdomain.com"
$NewPassword = "N3wP@ssw0rd"

# Reset the user's password
Set-MsolUserPassword -UserPrincipalName $UserPrincipalName -NewPassword $NewPassword -ForceChangePassword $false
