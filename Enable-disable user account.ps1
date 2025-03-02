# Define user properties
$Username = "jdoe"

# Enable the user
Enable-ADAccount -Identity $Username

# Disable the user
Disable-ADAccount -Identity $Username
