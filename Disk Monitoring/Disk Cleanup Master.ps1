<#
.SYNOPSIS
    Enterprise‑grade disk cleanup script for MSP environments.

.DESCRIPTION
    - Cleans temp files (system + user)
    - Empties recycle bin safely
    - Clears browser cache (Chrome, Edge, Firefox)
    - Clears Windows Update cache safely
    - Clears system event logs (optional)
    - Logs all actions with timestamps
    - Includes validation and error handling

.NOTES
    Author: Ajay Narasimhan
#>

[CmdletBinding()]
param(
    [switch]$ClearTemp,
    [switch]$ClearRecycleBin,
    [switch]$ClearLogs,
    [switch]$ClearBrowserCache,
    [switch]$ClearWindowsUpdates,
    [string]$LogPath = "C:\MSP\CleanupLogs"
)

# -----------------------------
# Helper Functions
# -----------------------------

function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp  $Message" | Out-File -FilePath $Global:LogFile -Append
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# -----------------------------
# Cleanup Functions
# -----------------------------

function Clear-TempFiles {
    Write-Log "Clearing temporary files..."
    $paths = @("C:\Windows\Temp", "$env:LOCALAPPDATA\Temp", "$env:TEMP")

    foreach ($path in $paths) {
        if (Test-Path $path) {
            try {
                Remove-Item "$path\*" -Recurse -Force -ErrorAction Stop
                Write-Log "Cleared: $path"
            }
            catch {
                Write-Log "ERROR clearing $path: $_"
            }
        }
    }
}

function Empty-RecycleBinSafe {
    Write-Log "Emptying Recycle Bin..."
    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Log "Recycle Bin emptied."
    }
    catch {
        Write-Log "ERROR emptying Recycle Bin: $_"
    }
}

function Clear-SystemLogsSafe {
    Write-Log "Clearing system event logs..."

    $logs = wevtutil el
    foreach ($log in $logs) {
        try {
            wevtutil cl "$log"
            Write-Log "Cleared log: $log"
        }
        catch {
            Write-Log "ERROR clearing log $log: $_"
        }
    }
}

function Clear-BrowserCacheSafe {
    Write-Log "Clearing browser cache..."

    $paths = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
        "$env:APPDATA\Mozilla\Firefox\Profiles"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            try {
                Remove-Item "$path\*" -Recurse -Force -ErrorAction Stop
                Write-Log "Cleared browser cache: $path"
            }
            catch {
                Write-Log "ERROR clearing browser cache $path: $_"
            }
        }
    }
}

function Clear-WindowsUpdateCache {
    Write-Log "Clearing Windows Update cache..."

    $service = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    if ($service.Status -eq "Running") {
        Stop-Service wuauserv -Force
        Write-Log "Stopped Windows Update service."
    }

    $path = "C:\Windows\SoftwareDistribution\Download"
    if (Test-Path $path) {
        try {
            Remove-Item "$path\*" -Recurse -Force -ErrorAction Stop
            Write-Log "Cleared Windows Update cache."
        }
        catch {
            Write-Log "ERROR clearing Windows Update cache: $_"
        }
    }

    Start-Service wuauserv
    Write-Log "Restarted Windows Update service."
}

# -----------------------------
# Initialization
# -----------------------------

Ensure-Directory -Path $LogPath
$Global:LogFile = Join-Path $LogPath ("Cleanup_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt")

Write-Log "Starting disk cleanup..."

# -----------------------------
# Execute Selected Tasks
# -----------------------------

if ($ClearTemp) { Clear-TempFiles }
if ($ClearRecycleBin) { Empty-RecycleBinSafe }
if ($ClearLogs) { Clear-SystemLogsSafe }
if ($ClearBrowserCache) { Clear-BrowserCacheSafe }
if ($ClearWindowsUpdates) { Clear-WindowsUpdateCache }

Write-Log "Disk cleanup completed."
Write-Host "Cleanup complete. Log saved to $Global:LogFile"
