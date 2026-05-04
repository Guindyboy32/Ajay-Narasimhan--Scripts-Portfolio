<#
.SYNOPSIS
    Redirects common user folders (Desktop, Documents, Pictures, Downloads)
    into the user's OneDrive directory.

.DESCRIPTION
    This script:
        - Validates the OneDrive path
        - Creates missing OneDrive subfolders
        - Updates User Shell Folder registry paths
        - Ensures consistent folder redirection

.AUTHOR
    Ajay Narasimhan
#>

# ==========================
# CONFIGURATION
# ==========================
$OneDrivePath = Join-Path $env:USERPROFILE "OneDrive"
$FoldersToRedirect = @("Desktop", "Documents", "Pictures", "Downloads")
$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"

# ==========================
# VALIDATION
# ==========================
if (-not (Test-Path $OneDrivePath)) {
    throw "OneDrive folder not found at: $OneDrivePath"
}

# ==========================
# REDIRECTION PROCESS
# ==========================
foreach ($Folder in $FoldersToRedirect) {

    $CurrentPath = Join-Path $env:USERPROFILE $Folder
    $NewPath = Join-Path $OneDrivePath $Folder

    # Create the OneDrive folder if missing
    if (-not (Test-Path $NewPath)) {
        New-Item -ItemType Directory -Path $NewPath -Force | Out-Null
    }

    # Update registry to redirect the folder
    New-ItemProperty -Path $RegistryPath -Name $Folder -Value $NewPath -Force | Out-Null
}

Write-Host "Selected folders successfully redirected to OneDrive." -ForegroundColor Green
