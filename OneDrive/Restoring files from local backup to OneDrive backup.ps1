<#
.SYNOPSIS
    Restores files from a OneDrive backup directory back into the user's
    OneDrive folder while preserving the original folder structure.

.DESCRIPTION
    This script:
        - Validates the backup and OneDrive paths
        - Recreates missing directories in OneDrive
        - Copies files from the backup into OneDrive
        - Preserves folder hierarchy
        - Provides clear status output

.AUTHOR
    Ajay Narasimhan – Systems Engineer
#>

# ==========================
# CONFIGURATION
# ==========================
$BackupPath   = "D:\OneDriveBackup"
$OneDrivePath = Join-Path $env:USERPROFILE "OneDrive"

# ==========================
# VALIDATION
# ==========================
if (-not (Test-Path $BackupPath)) {
    throw "Backup folder not found at: $BackupPath"
}

if (-not (Test-Path $OneDrivePath)) {
    throw "OneDrive folder not found at: $OneDrivePath"
}

Write-Host "Restoring backup from:`n$BackupPath`nTo:`n$OneDrivePath" -ForegroundColor Cyan

# ==========================
# RESTORE PROCESS
# ==========================
$Items = Get-ChildItem -Path $BackupPath -Recurse -Force -ErrorAction SilentlyContinue

foreach ($Item in $Items) {
    $Destination = $Item.FullName -replace [regex]::Escape($BackupPath), $OneDrivePath

    if ($Item.PSIsContainer) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }
    else {
        Copy-Item -Path $Item.FullName -Destination $Destination -Force
    }
}

Write-Host "Backup files restored to OneDrive successfully." -ForegroundColor Green
