<#
.SYNOPSIS
    Safely uninstalls Zoho Assist (MSI or EXE version) without using Win32_Product.

.DESCRIPTION
    Searches registry uninstall entries for Zoho Assist, executes the correct
    uninstall command silently, and removes leftover files if needed.
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
# Find Uninstall Command
# -----------------------------
function Get-UninstallCommand {
    param([string]$NamePattern)

    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($path in $paths) {
        $keys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
        foreach ($key in $keys) {
            $props = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
            if ($props.DisplayName -like $NamePattern) {
                return $props.UninstallString
            }
        }
    }

    return $null
}

# -----------------------------
# Uninstall Zoho Assist
# -----------------------------
function Uninstall-ZohoAssist {

    Write-Log "Searching for Zoho Assist uninstall entry..."

    $uninstallCmd = Get-UninstallCommand -NamePattern "Zoho*Assist*"

    if (-not $uninstallCmd) {
        Write-Log "Zoho Assist is not installed." "WARN"
        return
    }

    Write-Log "Found uninstall command: $uninstallCmd"

    # Normalize MSI uninstall commands
    if ($uninstallCmd -match "MsiExec\.exe") {
        Write-Log "Detected MSI-based uninstall. Running silently..."
        $args = $uninstallCmd.Replace("MsiExec.exe", "").Trim()
        Start-Process "msiexec.exe" -ArgumentList "$args /quiet /norestart" -Wait
    }
    else {
        Write-Log "Detected EXE-based uninstall. Running silently..."
        Start-Process -FilePath $uninstallCmd -ArgumentList "/S /quiet /silent" -Wait -ErrorAction SilentlyContinue
    }

    Write-Log "Zoho Assist uninstall command executed."
}

# -----------------------------
# Remove Leftover Zoho Files
# -----------------------------
function Remove-ZohoLeftovers {
    $paths = @(
        "C:\Program Files (x86)\ZohoMeeting",
        "C:\Program Files\ZohoMeeting",
        "C:\ProgramData\Zoho"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Write-Log "Removing leftover directory: $path"
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# -----------------------------
# Main Execution
# -----------------------------
Write-Log "Starting Zoho Assist removal workflow..."

Uninstall-ZohoAssist
Remove-ZohoLeftovers

Write-Log "Zoho Assist removal workflow complete."
exit 0
