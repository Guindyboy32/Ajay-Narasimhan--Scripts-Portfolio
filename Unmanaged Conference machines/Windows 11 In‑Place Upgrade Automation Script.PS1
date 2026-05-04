<#
.SYNOPSIS
Windows 11 In‑Place Upgrade Automation Script
Author: Ajay Narasimhan – Senior Systems Engineer

.DESCRIPTION
This script performs a controlled, validated in‑place upgrade to Windows 11
using the official Microsoft Windows 11 Installation Assistant.

It includes:
• Pre‑upgrade validation (disk, AC power, prerequisites)
• Optional rollback window extension
• Secure download of the Installation Assistant
• Silent staging of the upgrade
• Clear exit‑code handling and operator guidance

Run as Administrator.
#>

# -----------------------------
# Pre‑Run Operator Guidance
# -----------------------------
Write-Host "=== Windows 11 Upgrade Pre‑Flight Checklist ==="
Write-Host "• Verify backups for critical data"
Write-Host "• Ensure TPM 2.0, Secure Boot, and UEFI are enabled"
Write-Host "• Close Zoom Rooms and any installers"
Write-Host "• Disconnect unnecessary USB devices"
Write-Host "• Ensure ≥ 30 GB free on C:"
Write-Host "• Stable internet connection required (~4–5 GB download)"
Write-Host "==============================================`n"

# -----------------------------
# Environment Prep
# -----------------------------
$Temp = "$env:TEMP\Win11Upgrade"
New-Item -Path $Temp -ItemType Directory -Force | Out-Null

function Fail($Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

# -----------------------------
# Pre‑Checks
# -----------------------------

# Disk space check
$freeGB = [math]::Round((Get-PSDrive C).Free/1GB,2)
if ($freeGB -lt 30) {
    Fail "Insufficient disk space. Required: 30 GB. Available: $freeGB GB."
}

# AC power check (skip for desktops)
try {
    $battery = Get-CimInstance Win32_Battery -ErrorAction Stop
    $onAC = $battery.BatteryStatus -in 2,3,6
} catch {
    $onAC = $true  # Desktop or no battery
}

if (-not $onAC) {
    Fail "Device is not connected to AC power. Plug in before upgrading."
}

# -----------------------------
# Optional: Extend rollback window
# -----------------------------
Write-Host "Extending OS uninstall window to 30 days..."
Start-Process dism -ArgumentList '/Online','/Set-OSUninstallWindow','/Value:30' -Wait | Out-Null

# -----------------------------
# Download Windows 11 Installation Assistant
# -----------------------------
$Exe = Join-Path $Temp 'Win11InstallationAssistant.exe'
Write-Host "Downloading Windows 11 Installation Assistant..."
Invoke-WebRequest -UseBasicParsing `
    -Uri 'https://go.microsoft.com/fwlink/?linkid=2171764' `
    -OutFile $Exe

if (-not (Test-Path $Exe)) {
    Fail "Download failed. Installation Assistant not found."
}

# -----------------------------
# Launch Upgrade
# -----------------------------
Write-Host "Launching Windows 11 Installation Assistant silently..."
$proc = Start-Process -FilePath $Exe -ArgumentList '/quietinstall /noreboot' -PassThru -Wait
$code = $proc.ExitCode

Write-Host "Installation Assistant exit code: $code"
Write-Host "0 = Success"
Write-Host "3010 = Success, reboot required"
Write-Host "Other = Failure"

# -----------------------------
# Exit Code Handling
# -----------------------------
switch ($code) {
    0     { Write-Host "Upgrade staged successfully. Reboot to complete installation." }
    3010  { Write-Host "Upgrade staged successfully. A reboot is required to finalize." }
    default {
        Write-Host "Upgrade failed. Review logs:"
        Write-Host "  C:\$WINDOWS.~BT\Sources\Panther\setuperr.log"
        Write-Host "  C:\$WINDOWS.~BT\Sources\Panther\setupact.log"
        exit $code
    }
}

# Optional automatic reboot:
# Restart-Computer -Force
