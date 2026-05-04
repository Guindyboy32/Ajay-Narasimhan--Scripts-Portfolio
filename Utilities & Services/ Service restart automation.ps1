<#
.SYNOPSIS
Monitors a Windows service and restarts it automatically if it is not running.

.DESCRIPTION
This script checks the status of a specified Windows service, attempts to start it
if it is stopped, and logs all actions. Designed for scheduled task execution or
lightweight service monitoring.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# -----------------------------
# Configuration
# -----------------------------
$ServiceName = "ServiceName"
$LogPath     = "C:\Logs\ServiceMonitor.log"

# Ensure log directory exists
$logDir = Split-Path $LogPath
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Logging function
function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp  $Message" | Out-File -FilePath $LogPath -Append -Encoding UTF8
}

# -----------------------------
# Service Monitoring Logic
# -----------------------------
try {
    $service = Get-Service -Name $ServiceName -ErrorAction Stop
}
catch {
    Write-Log "ERROR: Service '$ServiceName' not found. $($_.Exception.Message)"
    return
}

if ($service.Status -ne "Running") {
    Write-Log "WARNING: Service '$ServiceName' is $($service.Status). Attempting restart..."

    try {
        Start-Service -Name $ServiceName -ErrorAction Stop
        Write-Log "SUCCESS: Service '$ServiceName' has been restarted."
    }
    catch {
        Write-Log "ERROR: Failed to start service '$ServiceName'. $($_.Exception.Message)"
    }
}
else {
    Write-Log "OK: Service '$ServiceName' is running."
}
