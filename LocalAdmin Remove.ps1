# Remove Local Admin account from administrators group
net localgroup administrators LocalAdmin /delete

# Delete Local Admin account
net user LocalAdmin /delete

# List all user accounts on the machine
$users = Get-WmiObject Win32_UserAccount
$perms = [System.Collections.ArrayList]@("Administrator", "DefaultAccount", "Guest", "LocalAdmin", "WDAGUtilityAccount")
$blacklist = [System.Collections.ArrayList]@()
if ($users.Count -eq 0) {
    Write-Output "No user accounts found on this machine."
} else {
    Write-Output "User accounts found on this machine:"
    foreach ($user in $users) {
        if ($perms.Contains($user.Name)){
            Write-Output "$user.Name already in permitted list."
        } else {
            $blacklist.Add($user)
            Write-Output "$user.Name added to the blacklist."
        }
    }
}

# CAUTION: DO NOT USE THE FOLLOWING CODE TO DELETE USERS UNLESS YOU FULLY UNDERSTAND THE CONSEQUENCES.
# Deleting user accounts can result in data loss and other unintended consequences.
# Uncomment the following code at your own risk:
foreach ($user in $blacklist) {
    if ($user.Name -ne "Administrator") {
        Write-Host "Deleting user account: $($user.Name)"
        # Remove-WmiObject only works for local accounts, not domain accounts
        # To delete domain accounts, you would need to use other methods such as net user or Active Directory cmdlets.
        Remove-LocalUser -Name "$($user.Name)"
        Write-Host "User account $($user.Name) deleted."
    } else {
        Write-Host "Skipping Administrator account deletion."
    }
}
