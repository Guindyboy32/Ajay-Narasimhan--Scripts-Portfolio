<#
.SYNOPSIS
    Enables TLS 1.2 for .NET Framework and SCHANNEL on Windows.

.DESCRIPTION
    Creates required registry keys and values to enforce TLS 1.2 usage
    for both .NET Framework (32‑bit and 64‑bit) and Windows SCHANNEL.

.NOTES
    Author: Ajay Narasimhan
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
# Registry Helper
# -----------------------------
function Ensure-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [int]$Value
    )

    if (-not (Test-Path $Path)) {
        Write-Log "Creating registry path: $Path" "DEBUG"
        New-Item -Path $Path -Force | Out-Null
    }

    Write-Log "Setting $Name = $Value at $Path" "DEBUG"
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
}

# -----------------------------
# .NET Framework TLS Settings
# -----------------------------
$DotNetPaths = @(
    "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319"
)

foreach ($path in $DotNetPaths) {
    Ensure-RegistryValue -Path $path -Name "SystemDefaultTlsVersions" -Value 1
    Ensure-RegistryValue -Path $path -Name "SchUseStrongCrypto" -Value 1
}

# -----------------------------
# SCHANNEL TLS 1.2 Settings
# -----------------------------
$SchannelPaths = @(
    "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server",
    "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client"
)

foreach ($path in $SchannelPaths) {
    Ensure-RegistryValue -Path $path -Name "Enabled" -Value 1
    Ensure-RegistryValue -Path $path -Name "DisabledByDefault" -Value 0
}

# -----------------------------
# Completion Message
# -----------------------------
Write-Log "TLS 1.2 has been enabled. A system restart is required for changes to take effect." "INFO"
