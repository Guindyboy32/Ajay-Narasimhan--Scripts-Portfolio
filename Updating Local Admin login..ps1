# Define the username and password for the new local administrator account
$username = "NewAdmin"
$password = ConvertTo-SecureString "Enterpasswordhere!" -AsPlainText -Force

# Create the new local administrator account with the password
New-LocalUser -Name $username -Password $password -AccountNeverExpires

# Add the new local administrator account to the Administrators group
Add-LocalGroupMember -Group "Administrators" -Member $username

Write-Output "Local administrator account '$username' created successfully with the password 'Enterpasswordhere'."
