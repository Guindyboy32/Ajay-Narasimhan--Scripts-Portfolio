# Variables
$daysInactive = 90
$targetOu = "OU=DisabledUsers,DC=domain,DC=com"

# Find Inactive Users
$inactiveUsers = Search-ADAccount -AccountInactive -TimeSpan (New-TimeSpan -Days $daysInactive) -UsersOnly

# Disable and Move Inactive Users
foreach ($user in $inactiveUsers) {
    Disable-ADAccount -Identity $user
    Move-ADObject -Identity $user.DistinguishedName -TargetPath $targetOu
}
