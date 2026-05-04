<#
.SYNOPSIS
Updates key Active Directory user attributes in a safe, validated, and auditable way.

.DESCRIPTION
This script checks whether the user exists, validates the properties being updated,
and applies changes with proper error handling. Designed for enterprise AD environments.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# ---------------------------------------------
# Configuration
# ---------------------------------------------
$Username        = "jdoe"
$NewDisplayName  = "Johnathan Doe"
$NewTitle        = "Senior Manager"
$NewDepartment   = "Sales"

# ---------------------------------------------
# Validate user exists
# ---------------------------------------------
try {
    $user = Get-ADUser -Identity $Username -ErrorAction Stop
}
catch {
    Write-Host "✖ ERROR: User '$Username' not found in Active Directory." -ForegroundColor Red
    return
}

Write-Host "✔ User found: $($user.SamAccountName)" -ForegroundColor Green

# ---------------------------------------------
# Apply updates
# ---------------------------------------------
try {
    Set-ADUser -Identity $Username `
               -DisplayName $NewDisplayName `
               -Title $NewTitle `
               -Department $NewDepartment

    Write-Host "✔ Successfully updated user '$Username'." -ForegroundColor Green
    Write-Host "  Display Name : $NewDisplayName"
    Write-Host "  Title        : $NewTitle"
    Write-Host "  Department   : $NewDepartment"
}
catch {
    Write-Host "✖ ERROR: Failed to update user '$Username'." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkYellow
}
