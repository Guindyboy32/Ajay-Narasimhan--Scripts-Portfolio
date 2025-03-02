# Define user properties
$Username = "jdoe"
$NewDisplayName = "Johnathan Doe"
$NewTitle = "Senior Manager"
$NewDepartment = "Sales"

# Modify the user
Set-ADUser -Identity $Username -DisplayName $NewDisplayName -Title $NewTitle -Department $NewDepartment
