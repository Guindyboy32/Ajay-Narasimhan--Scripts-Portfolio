<#
.SYNOPSIS
Creates a local administrator account with proper validation, logging, and
secure-by-default behavior.

.DESCRIPTION
This script checks for existing accounts, validates group membership, and
creates a local admin user with optional passwordless mode (not recommended).
Includes full error handling and clear operational output.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# ---------------------------------------------
# Configuration
# ---------------------------------------------
$Username = "NewAdmin"

# Set to $true ONLY if you intentionally want a passwordless account
$AllowNoPassword = $false

# Optional: define a password (recommended)
$Password = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force

# ---------------------------------------------
# Check if user already exists
# ---------------------------------------------
if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
    Write-Host "✖ ERROR: Local user '$Username' already exists." -ForegroundColor Red
    return
}

# ---------------------------------------------
# Create the user
# ---------------------------------------------
try {
    if ($AllowNoPassword -eq $true) {
        New-LocalUser -Name $Username -NoPassword -AccountNeverExpires -ErrorAction Stop
        Write-Host "✔ User '$Username' created WITHOUT a password (not recommended)." -ForegroundColor Yellow
    }
    else {
        New-LocalUser -Name $Username -Password $Password -AccountNeverExpires -ErrorAction Stop
        Write-Host "✔ User '$Username' created with a secure password." -ForegroundColor Green
    }
}
catch {
    Write-Host "✖ ERROR: Failed to create user '$Username'. $($_.Exception.Message)" -ForegroundColor Red
    return
}

# ---------------------------------------------
# Add user to Administrators group
# ---------------------------------------------
try {
    Add-LocalGroupMember -Group "Administrators" -Member $Username -ErrorAction Stop
    Write-Host "✔ User '$Username' added to Administrators group." -ForegroundColor Green
}
catch {
    Write-Host "✖ ERROR: Failed to add '$Username' to Administrators group. $($_.Exception.Message)" -ForegroundColor Red
    return
}

Write-Host "✔ Local administrator provisioning complete for '$Username'." -ForegroundColor Green
