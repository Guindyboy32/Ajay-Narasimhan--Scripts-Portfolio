<#
.SYNOPSIS
    Uninstalls SnapAgent and ZTAC, stops related services/processes,
    and removes leftover directories and registry keys.

.DESCRIPTION
    This script safely uninstalls applications by querying MSI uninstall
    entries from the registry instead of using Win32_Product. It also
    stops related services, kills processes, and removes residual files
    and registry keys.
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
    Write-Output "[$timestamp] [$Level] $Message"
}

# -----------------------------
# Safe MSI Uninstall Helper
# -----------------------------
function Get-MSIProductCode {
    param([string]$AppName)

    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($path in $paths) {
        $keys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
        foreach ($key in $keys) {
            $displayName = (Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -eq $AppName) {
                return (Get-ItemProperty -Path $key.PSPath).PSChildName
            }
        }
    }

    return $null
}

function Uninstall-Application {
    param([string]$AppName)

    Write-Log "Searching for MSI uninstall entry for $AppName..."

    $productCode = Get-MSIProductCode -AppName $AppName

    if ($null -eq $productCode) {
        Write-Log "No MSI product code found for $AppName. It may not be installed." "WARN"
        return
    }

    Write-Log "Uninstalling $AppName (ProductCode: $productCode)..."

    try {
        Start-Process -FilePath "msiexec.exe" `
            -ArgumentList "/x {$productCode} /quiet /norestart" `
            -Wait -ErrorAction Stop

        Write-Log "$AppName uninstalled successfully."
    }
    catch {
        Write-Log "Failed to uninstall $AppName: $($_.Exception.Message)" "ERROR"
    }
}

# -----------------------------
# Stop Processes and Services
# -----------------------------
function Stop-Target {
    param(
        [string]$Name,
        [string]$Type # "Process" or "Service"
    )

    if ($Type -eq "Process") {
        $proc = Get-Process -Name $Name -ErrorAction SilentlyContinue
        if ($proc) {
            Write-Log "Stopping process: $Name"
            Stop-Process -Name $Name -Force -ErrorAction SilentlyContinue
        }
        else {
            Write-Log "Process '$Name' not found." "DEBUG"
        }
    }

    if ($Type -eq "Service") {
        $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
        if ($svc) {
            Write-Log "Stopping service: $Name"
            Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
        }
        else {
            Write-Log "Service '$Name' not found." "DEBUG"
        }
    }
}

# -----------------------------
# Begin Removal Workflow
# -----------------------------
Write-Log "Starting SnapAgent + ZTAC removal workflow..."

# Stop Snap components
Stop-Target -Name "snapw" -Type "Process"
Stop-Target -Name "snap"  -Type "Service"
Start-Sleep -Seconds 3

# Uninstall SnapAgent
Uninstall-Application -AppName "SnapAgent"
Start-Sleep -Seconds 3

# Stop ZTAC components
Stop-Target -Name "ztac" -Type "Service"
Start-Sleep -Seconds 3

# Uninstall ZTAC
Uninstall-Application -AppName "ZTAC"
Start-Sleep -Seconds 3

# -----------------------------
# Remove leftover directories
# -----------------------------
$bpPath = "C:\Program Files (x86)\Blackpoint\"

if (Test-Path $bpPath) {
    Write-Log "Removing leftover directory: $bpPath"
    Remove-Item -Path $bpPath -Recurse -Force -ErrorAction SilentlyContinue
}

# -----------------------------
# Remove leftover registry keys
# -----------------------------
$registryKeys = @(
    "HKLM:\SOFTWARE\Classes\Installer\Features\0E1D3F0C2B974FA4AA0418F12B055384",
    "HKLM:\SOFTWARE\Classes\Installer\Products\0E1D3F0C2B974FA4AA0418F12B055384",
    "HKLM:\SOFTWARE\Classes\Installer\Products\0E1D3F0C2B974FA4AA0418F12B055384\SourceList",
    "HKLM:\SOFTWARE\Classes\Installer\Products\0E1D3F0C2B974FA4AA0418F12B055384\SourceList\Media",
    "HKLM:\SOFTWARE\Classes\Installer\Products\0E1D3F0C2B974FA4AA0418F12B055384\SourceList\Net",
    "HKLM:\SOFTWARE\Classes\Installer\UpgradeCodes\7CF0653F8B24F2647B3A70510A96BEE6",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\7CF0653F8B24F2647B3A70510A96BEE6",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\08C8C87010175A141912F6695F06EB95",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\5E3D36BBC4ADCA749AC6CC3774478B04"
)

foreach ($key in $registryKeys) {
    if (Test-Path $key) {
        Write-Log "Removing registry key: $key"
        Remove-Item -Path $key -Force -Recurse -ErrorAction SilentlyContinue
    }
}

Write-Log "Removal workflow complete."
exit 0
