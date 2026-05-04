<#
.SYNOPSIS
Creates a local administrator account with proper validation and secure handling.

.DESCRIPTION
This script checks for existing accounts, creates a new local admin user with a
secure password, and adds the user to the Administrators group. Includes full
error handling and avoids exposing credentials.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# ---------------------------------------------
# Configuration
# ---------------------------------------------
$Username = "NewAdmin"
$Password = ConvertTo-SecureString "Enterpasswordhere!" -AsPlainText -Force

# ---------------------------------------------
# Check if the user already exists
# ---------------------------------------------
if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue) {
    Write-Host "✖ ERROR: Local user '$Username' already exists." -ForegroundColor Red
    return
}

# ---------------------------------------------
# Create the local user
# ---------------------------------------------
try {
    New-LocalUser -Name $Username `
                  -Password $Password `
                  -AccountNeverExpires `
                  -ErrorAction Stop

    Write-Host "✔ Local user '$Username' created successfully." -ForegroundColor Green
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
    Write-Host "✔ '$Username' added to Administrators group." -ForegroundColor Green
}
catch {
    Write-Host "✖ ERROR: Failed to add '$Username' to Administrators group. $($_.Exception.Message)" -ForegroundColor Red
    return
}

Write-Host "✔ Local administrator provisioning complete for '$Username'." -ForegroundColor Green
