<#
.SYNOPSIS
    Restores all items from the Windows Recycle Bin.

.DESCRIPTION
    Uses the Microsoft.VisualBasic FileSystem class to enumerate and restore
    all items currently in the Recycle Bin. Includes logging and error handling.
#>

# -----------------------------
# Load Required Assembly
# -----------------------------
try {
    Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction Stop
}
catch {
    Write-Host "Failed to load Microsoft.VisualBasic assembly: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# -----------------------------
# Logging Helper
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
# Restore Recycle Bin Items
# -----------------------------
try {
    $items = [Microsoft.VisualBasic.FileIO.FileSystem]::GetRecycleBinItems()

    if ($items.Count -eq 0) {
        Write-Log "Recycle Bin is already empty." "INFO"
        exit 0
    }

    Write-Log "Restoring $($items.Count) item(s) from the Recycle Bin..."

    foreach ($item in $items) {
        try {
            [Microsoft.VisualBasic.FileIO.FileSystem]::RestoreFromRecycleBin($item)
            Write-Log "Restored: $($item.Name)" "DEBUG"
        }
        catch {
            Write-Log "Failed to restore: $($item.Name) — $($_.Exception.Message)" "WARN"
        }
    }

    Write-Log "All possible items have been restored."
}
catch {
    Write-Log "Unexpected error while restoring Recycle Bin items: $($_.Exception.Message)" "ERROR"
    exit 1
}

exit 0
