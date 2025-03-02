# Define user properties
$Username = "jdoe"
$Password = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
$DisplayName = "John Doe"
$OU = "OU=Users,DC=example,DC=com"
$Email = "jdoe@example.com"
$Department = "Sales"
$Title = "Sales Executive"
$HomeDirectory = "\\server\users\jdoe"

# Create the user
New-ADUser -Name $Username -AccountPassword $Password -PasswordNeverExpires $true -Enabled $true -DisplayName $DisplayName -Path $OU -UserPrincipalName "$Username@example.com" -SamAccountName $Username -EmailAddress $Email -Department $Department -Title $Title -HomeDirectory $HomeDirectory -HomeDrive "H:"

# Add user to groups
Add-ADGroupMember -Identity "Sales Team" -Members $Username
Add-ADGroupMember -Identity "VPN Users" -Members $Username
