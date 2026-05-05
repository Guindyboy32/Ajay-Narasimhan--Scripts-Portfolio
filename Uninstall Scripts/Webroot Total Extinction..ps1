<#
.SYNOPSIS
    Fully removes Webroot SecureAnywhere and all related components.

.DESCRIPTION
    Stops Webroot services, runs the official uninstaller, removes leftover
    folders, registry keys, scheduled tasks, and startup entries.
#>

# -----------------------------
# Logging
# -----------------------------
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "MM/dd/yy HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

Write-Log "Starting Webroot removal workflow..."

# -----------------------------
# Stop and Disable Services
# -----------------------------
$Services = @(
    "WRSVC","WRkrn","WRBoot","WRCore","WRCoreService","wrUrlFlt"
)

foreach ($svc in $Services) {
    $serviceObj = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($serviceObj) {
        Write-Log "Stopping service: $svc"
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Write-Log "Disabling service: $svc"
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

# -----------------------------
# Run Webroot Uninstaller
# -----------------------------
$wrsaPath = "$env:ProgramFiles\Webroot\WRSA.exe"

if (Test-Path $wrsaPath) {
    Write-Log "Running Webroot uninstaller..."
    Start-Process -FilePath $wrsaPath -ArgumentList "-uninstall" -Wait -ErrorAction SilentlyContinue
} else {
    Write-Log "WRSA.exe not found. Continuing with manual cleanup." "WARN"
}

Start-Sleep -Seconds 3

# -----------------------------
# Remove Scheduled Tasks
# -----------------------------
$Tasks = @(
    "\Webroot SecureAnywhere",
    "\Webroot SecureAnywhere Global Scan",
    "\Webroot SecureAnywhere Instant Scan"
)

foreach ($task in $Tasks) {
    Write-Log "Removing scheduled task: $task"
    schtasks /delete /tn $task /f 2>$null
}

# -----------------------------
# Remove Startup Entries
# -----------------------------
$StartupPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($path in $StartupPaths) {
    if (Test-Path $path) {
        Write-Log "Removing Webroot startup entries from: $path"
        Get-ItemProperty -Path $path | ForEach-Object {
            if ($_ -match "webroot|wrsa|wrdata|wrcore") {
                Remove-ItemProperty -Path $path -Name $_.PSChildName -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

# -----------------------------
# Remove Folders
# -----------------------------
$Folders = @(
    "$env:ProgramFiles\Webroot",
    "$env:ProgramFiles(x86)\Webroot",
    "$env:ProgramData\WRData",
    "$env:ProgramData\WRCore",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Webroot SecureAnywhere"
)

foreach ($folder in $Folders) {
    if (Test-Path $folder) {
        Write-Log "Removing folder: $folder"
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# -----------------------------
# Remove Registry Keys
# -----------------------------
$RegKeys = @(
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\WRUNINST",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\WRUNINST",
    "HKLM:\SOFTWARE\WOW6432Node\WRData",
    "HKLM:\SOFTWARE\WOW6432Node\WRCore",
    "HKLM:\SOFTWARE\WOW6432Node\WRMIDData",
    "HKLM:\SOFTWARE\WOW6432Node\webroot",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WRUNINST",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WRUNINST",
    "HKLM:\SOFTWARE\WRData",
    "HKLM:\SOFTWARE\WRMIDData",
    "HKLM:\SOFTWARE\WRCore",
    "HKLM:\SOFTWARE\webroot",
    "HKLM:\SYSTEM\CurrentControlSet\Services\WRSVC",
    "HKLM:\SYSTEM\CurrentControlSet\Services\WRkrn",
    "HKLM:\SYSTEM\CurrentControlSet\Services\WRBoot",
    "HKLM:\SYSTEM\CurrentControlSet\Services\WRCore",
    "HKLM:\SYSTEM\CurrentControlSet\Services\WRCoreService",
    "HKLM:\SYSTEM\CurrentControlSet\Services\wrUrlFlt"
)

foreach ($key in $RegKeys) {
    if (Test-Path $key) {
        Write-Log "Removing registry key: $key"
        Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Log "Webroot removal workflow complete."
exit 0
