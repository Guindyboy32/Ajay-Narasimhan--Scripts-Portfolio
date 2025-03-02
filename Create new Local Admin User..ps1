# Define the username for the new local administrator account
$username = "NewAdmin"
 
# Create the new local administrator account without a password
New-LocalUser -Name $username -NoPassword -AccountNeverExpires
 
# Add the new local administrator account to the Administrators group
Add-LocalGroupMember -Group "Administrators" -Member $username
 
Write-Output "Local administrator account '$username' created successfully without a password requirement."