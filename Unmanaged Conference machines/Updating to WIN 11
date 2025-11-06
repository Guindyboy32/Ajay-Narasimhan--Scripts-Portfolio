##Verify before running (to avoid surprises)
##Run as Administrator.
##Back up anything important (upgrade keeps apps/data, but best practice).
##Ensure TPM 2.0, Secure Boot, UEFI are enabled (or the Assistant will refuse).
##Free space ≥ 30 GB on C:.
##Close Zoom Rooms app and any installers; disconnect unnecessary USB devices.
##Temporarily pause aggressive AV/EDR if you’ve seen upgrade blocks.
##Stable internet (the tool downloads ~4–5 GB).
##After running
##If exit code is 0 or 3010, reboot to complete the upgrade.
##Verify with winver, then spot-check your key apps (including Zoom Rooms).
##If needed, you can roll back within the uninstall window (default 10 days, or 30 if you used the DISM line).

# How to run. Copy to USB Drive and save C:\Temp
#Run With Powershell below
# Set-ExecutionPolicy Bypass -Scope Process -Force cd C:\Temp.\USB-Win11-Upgrade.ps1



# Run as Administrator
$Temp = "$env:TEMP\Win11Upgrade"
New-Item -Path $Temp -ItemType Directory -Force | Out-Null

# Basic prechecks (recommended)
function Fail($m){ Write-Host $m; exit 1 }
$freeGB = [math]::Round((Get-PSDrive C).Free/1GB,2)
if ($freeGB -lt 30) { Fail "Not enough free space on C:. Need >= 30 GB (have $freeGB GB)." }

try { $onAC = (Get-CimInstance Win32_Battery -ErrorAction Stop).BatteryStatus -in 2,3,6 } catch { $onAC = $true }
if (-not $onAC) { Fail "Please plug the device into AC power before upgrading." }

# Optional: extend rollback window to 30 days (do this before first reboot post-upgrade)
Start-Process dism -ArgumentList '/Online','/Set-OSUninstallWindow','/Value:30' -Wait | Out-Null

# Download official Installation Assistant
$Exe = Join-Path $Temp 'Win11InstallationAssistant.exe'
Invoke-WebRequest -UseBasicParsing -Uri 'https://go.microsoft.com/fwlink/?linkid=2171764' -OutFile $Exe

Write-Host "Launching Windows 11 Installation Assistant..."
$proc = Start-Process -FilePath $Exe -ArgumentList '/quietinstall /noreboot' -PassThru -Wait
$code = $proc.ExitCode
Write-Host "Installation Assistant exit code: $code (0=success, 3010=success+reboot required)"

if ($code -in 0,3010) {
  Write-Host "Upgrade staged successfully."
  # Reboot now if you want to finish immediately:
  # Restart-Computer -Force
} else {
  Write-Host "Upgrade failed. Check C:\$WINDOWS.~BT\Sources\Panther\setuperr.log and setupact.log"
  exit $code
}
