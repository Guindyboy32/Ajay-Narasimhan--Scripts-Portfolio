<#
.SYNOPSIS
    Safely uninstalls MSP360 Backup without using Win32_Product.

.DESCRIPTION
    Searches the registry for the MSP360 Backup MSI product code and
    uninstalls it silently using msiexec. Includes logging and error handling.
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

# -----------------------------
# Find MSI Product Code Safely
# -----------------------------
function Get-MSIProductCode {
    param([string]$NamePattern)

    $uninstallPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($path in $uninstallPaths) {
        $keys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
        foreach ($key in $keys) {
            $props = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
            if ($props.DisplayName -like $NamePattern) {
                return $props.PSChildName
            }
        }
    }

    return $null
}

# -----------------------------
# Uninstall MSP360 Backup
# -----------------------------
Write-Log "Searching for MSP360 Backup installation..."

$productCode = Get-MSIProductCode -NamePattern "MSP360*Backup*"

if ($null -eq $productCode) {
    Write-Log "MSP360 Backup is not installed." "WARN"
    exit 0
}

Write-Log "Found MSP360 Backup (ProductCode: {$productCode}). Beginning uninstall..."

try {
    Start-Process -FilePath "msiexec.exe" `
        -ArgumentList "/x {$productCode} /quiet /norestart" `
        -Wait -ErrorAction Stop

    Write-Log "MSP360 Backup has been uninstalled successfully." "INFO"
}
catch {
    Write-Log "Uninstall failed: $($_.Exception.Message)" "ERROR"
    exit 1
}

exit 0
