<#
.SYNOPSIS
    Removes files from the user's OneDrive folder that are older than a defined
    retention period.

.DESCRIPTION
    This script:
        - Validates the OneDrive path
        - Defines a retention period (default: 30 days)
        - Identifies files older than the retention threshold
        - Deletes them safely
        - Logs all actions and errors

.AUTHOR
    Ajay Narasimhan – Systems Engineer
#>

param(
    [int]$RetentionDays = 30
)

# ==========================
# CONFIGURATION
# ==========================
$OneDrivePath = Join-Path $env:USERPROFILE "OneDrive"
$LogPath = "$env:USERPROFILE\OneDriveCleanup.log"
$RetentionDate = (Get-Date).AddDays(-$RetentionDays)

# ==========================
# LOGGING
# ==========================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$timestamp][$Level] $Message"
}

# ==========================
# VALIDATION
# ==========================
if (-not (Test-Path $OneDrivePath)) {
    Write-Log "OneDrive path not found: $OneDrivePath" "ERROR"
    throw "OneDrive folder not found at: $OneDrivePath"
}

Write-Log "Starting OneDrive cleanup. Retention: $RetentionDays days"

# ==========================
# CLEANUP PROCESS
# ==========================
$Files = Get-ChildItem -Path $OneDrivePath -Recurse -File -Force -ErrorAction SilentlyContinue |
         Where-Object { $_.LastWriteTime -lt $RetentionDate }

foreach ($File in $Files) {
    try {
        Remove-Item -Path $File.FullName -Force
        Write-Log "Deleted: $($File.FullName)"
    }
    catch {
        Write-Log "Failed to delete: $($File.FullName) - $($_.Exception.Message)" "ERROR"
    }
}

Write-Log "Cleanup completed successfully."
Write-Host "Old OneDrive files cleaned up successfully." -ForegroundColor Green
