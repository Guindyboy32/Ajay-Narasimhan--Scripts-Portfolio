<#
.SYNOPSIS
    Restarts the OneDrive process and triggers an immediate sync.

.DESCRIPTION
    This script:
        - Stops any running OneDrive instance
        - Restarts OneDrive cleanly
        - Initiates a manual sync using the /syncnow switch

.AUTHOR
    Ajay Narasimhan – Systems Engineer
#>

# ==========================
# STOP EXISTING ONEDRIVE PROCESS
# ==========================
Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue

# ==========================
# START ONEDRIVE WITH SYNC
# ==========================
$OneDriveExe = Join-Path $env:LOCALAPPDATA "Microsoft\OneDrive\OneDrive.exe"

if (Test-Path $OneDriveExe) {
    Start-Process -FilePath $OneDriveExe -ArgumentList "/syncnow"
    Write-Host "OneDrive sync initiated." -ForegroundColor Green
}
else {
    Write-Host "OneDrive executable not found. Ensure OneDrive is installed." -ForegroundColor Red
}
