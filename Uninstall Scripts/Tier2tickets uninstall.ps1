<#
.SYNOPSIS
    Safely uninstalls the Tier2Tickets application without using Win32_Product.

.DESCRIPTION
    Searches the registry for the MSI product code associated with Tier2Tickets
    and uninstalls it silently using msiexec. Includes logging and error handling.
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
            if ($props.DisplayName -eq $NamePattern) {
                return $props.PSChildName
            }
        }
    }

    return $null
}

# -----------------------------
# Uninstall Application
# -----------------------------
function Uninstall-Software {
    param([string]$Name)

    Write-Log "Searching for $Name installation..."

    $productCode = Get-MSIProductCode -NamePattern $Name

    if ($null -eq $productCode) {
        Write-Log "$Name is not installed." "WARN"
        return $false
    }

    Write-Log "Found $Name (ProductCode: {$productCode}). Beginning uninstall..."

    try {
        Start-Process -FilePath "msiexec.exe" `
            -ArgumentList "/x {$productCode} /quiet /norestart" `
            -Wait -ErrorAction Stop

        Write-Log "$Name uninstalled successfully." "INFO"
        return $true
    }
    catch {
        Write-Log "Uninstall failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# -----------------------------
# Main Execution
# -----------------------------
$softwareName = "Tier2Tickets"

if (Uninstall-Software -Name $softwareName) {
    Write-Log "Uninstallation completed successfully."
} else {
    Write-Log "Uninstallation did not complete or the software was not found." "WARN"
}

exit 0
