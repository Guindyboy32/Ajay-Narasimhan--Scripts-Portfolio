<#
.SYNOPSIS
    Installs the Mimecast Outlook add‑in silently and closes Outlook if running.

.DESCRIPTION
    This script checks for any running Outlook processes, closes them cleanly,
    and then installs the Mimecast add‑in via MSIEXEC in quiet mode.
#>

# -----------------------------
# Configuration
# -----------------------------
$InstallerPath = "Mimecast for outlook 7.10.1.133 (x64).msi"

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
# Close Outlook if running
# -----------------------------
try {
    $outlook = Get-Process -Name "OUTLOOK" -ErrorAction SilentlyContinue

    if ($outlook) {
        Write-Log "Outlook is running. Attempting to close..."

        $outlook.CloseMainWindow() | Out-Null
        Start-Sleep -Seconds 2

        if (!$outlook.HasExited) {
            Write-Log "Outlook did not close gracefully. Forcing termination..." "WARN"
            $outlook | Stop-Process -Force
        }

        Write-Log "Outlook closed successfully."
    }
    else {
        Write-Log "Outlook is not running."
    }
}
catch {
    Write-Log "Error while closing Outlook: $($_.Exception.Message)" "ERROR"
}

# -----------------------------
# Install Mimecast Add‑in
# -----------------------------
if (-not (Test-Path $InstallerPath)) {
    Write-Log "Installer not found at: $InstallerPath" "ERROR"
    exit 1
}

Write-Log "Starting Mimecast Outlook add‑in installation..."

try {
    Start-Process -FilePath "msiexec.exe" `
        -ArgumentList "/i `"$InstallerPath`" /quiet /norestart" `
        -Wait -ErrorAction Stop

    Write-Log "Mimecast add‑in installation completed."
}
catch {
    Write-Log "Installation failed: $($_.Exception.Message)" "ERROR"
    exit 1
}

exit 0
