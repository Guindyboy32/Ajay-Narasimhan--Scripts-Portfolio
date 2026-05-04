<#
.SYNOPSIS
    Sends a wipe command to an Intune-managed device with full validation,
    confirmation prompts, and error handling.

.DESCRIPTION
    This script:
        - Validates Microsoft Graph module availability
        - Connects to Graph with required scopes
        - Confirms the device exists before wiping
        - Requires explicit user confirmation ("YES")
        - Logs all actions and errors
        - Prevents accidental destructive operations

.VERSION
    2.0

.AUTHOR
    Ajay Narasimhan – Systems Engineer
#>

# ==========================
# CONFIGURATION
# ==========================
$LogPath = "$env:USERPROFILE\IntuneDeviceWipe.log"
$RequiredScopes = @("DeviceManagementManagedDevices.PrivilegedOperations.All")

# ==========================
# LOGGING
# ==========================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$timestamp][$Level] $Message"
}

# ==========================
# MODULE VALIDATION
# ==========================
function Test-GraphModule {
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
        Write-Log "Microsoft Graph module not installed" "ERROR"
        throw "Microsoft Graph module is not installed. Install it using: Install-Module Microsoft.Graph"
    }
}

# ==========================
# GRAPH CONNECTION
# ==========================
function Connect-GraphSafe {
    try {
        Write-Log "Connecting to Microsoft Graph..."
        Connect-MgGraph -Scopes $RequiredScopes -ErrorAction Stop
        Write-Log "Connected to Microsoft Graph successfully"
    }
    catch {
        Write-Log "Graph connection failed: $($_.Exception.Message)" "ERROR"
        throw "Failed to connect to Microsoft Graph. Check permissions and try again."
    }
}

# ==========================
# VALIDATE DEVICE EXISTS
# ==========================
function Get-DeviceById {
    param([string]$DeviceId)

    try {
        $device = Get-MgDeviceManagementManagedDevice -ManagedDeviceId $DeviceId -ErrorAction Stop
        Write-Log "Device found: $($device.DeviceName)"
        return $device
    }
    catch {
        Write-Log "Device not found: $DeviceId" "ERROR"
        throw "No Intune device found with ID: $DeviceId"
    }
}

# ==========================
# SEND WIPE COMMAND
# ==========================
function Invoke-DeviceWipe {
    param([string]$DeviceId)

    Write-Host "WARNING: You are about to WIPE the following device:" -ForegroundColor Yellow
    Write-Host "Device ID: $DeviceId" -ForegroundColor Yellow
    Write-Host "This action is IRREVERSIBLE." -ForegroundColor Red

    $confirm = Read-Host "Type YES to continue"

    if ($confirm -ne "YES") {
        Write-Host "Wipe cancelled." -ForegroundColor Cyan
        Write-Log "Wipe cancelled by user"
        return
    }

    try {
        Write-Log "Sending wipe command to device $DeviceId"
        Invoke-MgDeviceManagementManagedDeviceWipe -ManagedDeviceId $DeviceId -ErrorAction Stop
        Write-Log "Wipe command sent successfully"
        Write-Host "Wipe command sent successfully." -ForegroundColor Green
    }
    catch {
        Write-Log "Wipe failed: $($_.Exception.Message)" "ERROR"
        throw "Failed to send wipe command: $($_.Exception.Message)"
    }
}

# ==========================
# MAIN EXECUTION
# ==========================
param(
    [Parameter(Mandatory)]
    [string]$DeviceId
)

try {
    Test-GraphModule
    Connect-GraphSafe
    $device = Get-DeviceById -DeviceId $DeviceId
    Invoke-DeviceWipe -DeviceId $DeviceId
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
