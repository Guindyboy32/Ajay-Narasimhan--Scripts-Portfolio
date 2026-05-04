<#
.SYNOPSIS
    Checks whether the OneDrive process is currently running.

.DESCRIPTION
    This script:
        - Queries the OneDrive process
        - Provides clear output indicating its status

.AUTHOR
    Ajay Narasimhan – Systems Engineer
#>

# ==========================
# CHECK ONEDRIVE PROCESS
# ==========================
$OneDriveProcess = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue

if ($OneDriveProcess) {
    Write-Host "OneDrive is running." -ForegroundColor Green
}
else {
    Write-Host "OneDrive is not running. Please start OneDrive." -ForegroundColor Yellow
}
