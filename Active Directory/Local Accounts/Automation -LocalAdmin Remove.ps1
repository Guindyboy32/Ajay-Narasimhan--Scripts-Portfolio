<#
.SYNOPSIS
Safely removes a specific local admin account and audits all local user accounts.

.DESCRIPTION
This script:
1. Removes a known local admin account from the Administrators group.
2. Deletes that account safely.
3. Audits all local user accounts and identifies non‑standard accounts.
4. Provides an optional, explicitly‑enabled cleanup step for deleting unwanted accounts.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# ---------------------------------------------
# Configuration
# ---------------------------------------------
$TargetAdmin = "LocalAdmin"   # The account you want to remove
$AllowedAccounts = @(
    "Administrator",
    "DefaultAccount",
    "Guest",
    "WDAGUtilityAccount",
    $TargetAdmin
)

# Set to $true ONLY if you want to delete accounts automatically
$EnableDeletion = $false

# ---------------------------------------------
# Step 1: Remove target admin from Administrators group
# ---------------------------------------------
try {
    net localgroup administrators $TargetAdmin /delete
    Write-Host "✔ Removed '$TargetAdmin' from Administrators group."
}
catch {
    Write-Host "✖ Failed to remove '$TargetAdmin' from Administrators group. $($_.Exception.Message)" -ForegroundColor Red
}

# ---------------------------------------------
# Step 2: Delete the target admin account
# ---------------------------------------------
try {
    net user $TargetAdmin /delete
    Write-Host "✔ Deleted local account '$TargetAdmin'."
}
catch {
    Write-Host "✖ Failed to delete '$TargetAdmin'. $($_.Exception.Message)" -ForegroundColor Red
}

# ---------------------------------------------
# Step 3: Audit all local user accounts
# ---------------------------------------------
$users = Get-LocalUser
$BlackList = @()

Write-Host "`n===== Local User Account Audit ====="

foreach ($user in $users) {
    if ($AllowedAccounts -contains $user.Name) {
        Write-Host "✔ $($user.Name) is permitted."
    }
    else {
        Write-Host "⚠ $($user.Name) is NOT in the permitted list."
        $BlackList += $user.Name
    }
}

# ---------------------------------------------
# Step 4: Optional deletion of blacklisted accounts
# ---------------------------------------------
if ($EnableDeletion -eq $true) {

    Write-Host "`n===== DELETION MODE ENABLED =====" -ForegroundColor Yellow

    foreach ($user in $BlackList) {
        if ($user -eq "Administrator") {
            Write-Host "Skipping built‑in Administrator account."
            continue
        }

        try {
            Remove-LocalUser -Name $user
            Write-Host "✔ Deleted user account: $user"
        }
        catch {
            Write-Host "✖ Failed to delete $user. $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
else {
    Write-Host "`nDeletion mode is OFF. No accounts were removed." -ForegroundColor Cyan
    Write-Host "To enable deletion, set:  `$EnableDeletion = \$true"
}
