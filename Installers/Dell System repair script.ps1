<#
.SYNOPSIS
    Silently launches Dell SupportAssist OS Recovery if installed.

.DESCRIPTION
    This script checks for the presence of SupportAssist OS Recovery and,
    if found, triggers a silent system repair process. It includes improved
    logging, validation, and error handling.

.NOTES
    Author: Ajay Narasimhan (rewritten version)
#>

# -----------------------------
# Configuration
# -----------------------------
$SupportAssistPath = "C:\Program Files\Dell\SupportAssistOSRecovery\SupportAssistOSRecovery.exe"

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
# Main Logic
# -----------------------------
try {
    Write-Log "Checking for Dell SupportAssist OS Recovery..."

    if (Test-Path $SupportAssistPath) {
        Write-Log "SupportAssist OS Recovery detected. Initiating silent repair..."

        Start-Process -FilePath $SupportAssistPath -ArgumentList "/silent" -Wait -ErrorAction Stop

        Write-Log "System repair initiated successfully."
    }
    else {
        Write-Log "SupportAssist OS Recovery not found. Installation may be missing or located elsewhere." "WARN"
    }
}
catch {
    Write-Log "Failed to initiate system repair: $($_.Exception.Message)" "ERROR"
    exit 1
}

exit 0
