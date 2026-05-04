<#
.SYNOPSIS
Creates a new Active Directory user with full attribute configuration and
adds the user to required security groups.

.DESCRIPTION
This script validates the OU, checks for existing accounts, creates the user,
configures attributes, sets the home directory, and adds the user to groups
with full error handling.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# ---------------------------------------------
# Configuration
# ---------------------------------------------
$Username       = "jdoe"
$Password       = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
$DisplayName    = "John Doe"
$OU             = "OU=Users,DC=example,DC=com"
$Email          = "jdoe@example.com"
$Department     = "Sales"
$Title          = "Sales Executive"
$HomeDirectory  = "\\server\users\jdoe"
$HomeDrive      = "H:"
$GroupsToAdd    = @("Sales Team", "VPN Users")

# ---------------------------------------------
# Validate OU
# ---------------------------------------------
try {
    $ouCheck = Get-ADOrganizationalUnit -Identity $OU -ErrorAction Stop
}
catch {
    Write-Host "✖ ERROR: OU '$OU' not found." -ForegroundColor Red
    return
}

# ---------------------------------------------
# Check if user already exists
# ---------------------------------------------
if (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue) {
    Write-Host "✖ ERROR: User '$Username' already exists in AD." -ForegroundColor Red
    return
}

# ---------------------------------------------
# Create the user
# ---------------------------------------------
try {
    New-ADUser `
        -Name $DisplayName `
        -SamAccountName $Username `
        -UserPrincipalName "$Username@example.com" `
        -AccountPassword $Password `
        -Enabled $true `
        -PasswordNeverExpires $true `
        -DisplayName $DisplayName `
        -EmailAddress $Email `
        -Department $Department `
        -Title $Title `
        -Path $OU `
        -HomeDirectory $HomeDirectory `
        -HomeDrive $HomeDrive

    Write-Host "✔ User '$Username' created successfully." -ForegroundColor Green
}
catch {
    Write-Host "✖ ERROR: Failed to create user '$Username'." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkYellow
    return
}

# ---------------------------------------------
# Create home directory if missing
# ---------------------------------------------
try {
    if (-not (Test-Path $HomeDirectory)) {
        New-Item -Path $HomeDirectory -ItemType Directory -Force | Out-Null
        Write-Host "✔ Home directory created at $HomeDirectory"
    }
}
catch {
    Write-Host "✖ WARNING: Failed to create home directory. $($_.Exception.Message)" -ForegroundColor Yellow
}

# ---------------------------------------------
# Add user to groups
# ---------------------------------------------
foreach ($group in $GroupsToAdd) {
    try {
        Add-ADGroupMember -Identity $group -Members $Username -ErrorAction Stop
        Write-Host "✔ Added '$Username' to group '$group'"
    }
    catch {
        Write-Host "✖ ERROR: Failed to add '$Username' to group '$group'. $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "✔ User provisioning completed for '$Username'." -ForegroundColor Green
