<#
.SYNOPSIS
    Creates a full backup of the user's OneDrive folder to a specified location
    with validation, error handling, and structured logging.

.DESCRIPTION
    This script:
        - Validates OneDrive and backup paths
        - Creates the backup directory if missing
        - Recursively copies files while preserving structure
        - Logs all actions and errors
        - Provides clear status output

.AUTHOR
    Ajay Narasimhan – Systems Engineer
#>

param(
    [string]$BackupPath = "D:\OneDriveBackup"
)

# ==========================
# CONFIGURATION
# ==========================
$OneDrivePath = Join-Path $env:USERPROFILE "OneDrive"
$LogPath = "$env:USERPROFILE\OneDriveBackup.log"

# ==========================
# LOGGING
# ==========================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$timestamp][$Level] $Message"
}

# ==========================
# VALIDATE PATHS
# ==========================
if (-not (Test-Path $OneDrivePath)) {
    Write-Log "OneDrive path not found: $OneDrivePath" "ERROR"
    throw "OneDrive folder not found at: $OneDrivePath"
}

if (-not (Test-Path $BackupPath)) {
    Write-Log "Backup folder missing. Creating: $BackupPath"
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
}

Write-Log "Starting OneDrive backup..."
Write-Host "Backing up OneDrive from:`n$OneDrivePath`nTo:`n$BackupPath" -ForegroundColor Cyan

# ==========================
# BACKUP PROCESS
# ==========================
$Items = Get-ChildItem -Path $OneDrivePath -Recurse -Force -ErrorAction SilentlyContinue

foreach ($Item in $Items) {
    try {
        $Destination = $Item.FullName -replace [regex]::Escape($OneDrivePath), $BackupPath

        if ($Item.PSIsContainer) {
            New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        }
        else {
            Copy-Item -Path $Item.FullName -Destination $Destination -Force
        }
    }
    catch {
        Write-Log "Failed to copy: $($Item.FullName) - $($_.Exception.Message)" "ERROR"
    }
}

Write-Log "Backup completed successfully."
Write-Host "OneDrive backup completed successfully." -ForegroundColor Green
