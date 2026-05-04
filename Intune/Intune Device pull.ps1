<#
.SYNOPSIS
    Retrieves Intune-managed devices using Microsoft Graph with validation,
    pagination support, and optional CSV export.

.DESCRIPTION
    This script:
        - Validates Microsoft Graph module availability
        - Connects to Graph with required scopes
        - Handles paginated Intune device results
        - Provides clean, structured output
        - Supports optional CSV export
        - Logs errors and connection failures
        - Uses modular, maintainable functions

.VERSION
    2.0

.AUTHOR
    Ajay Narasimhan
#>

# ==========================
# CONFIGURATION
# ==========================
$LogPath = "$env:USERPROFILE\IntuneDeviceReport.log"
$RequiredScopes = @("Device.Read.All")

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
# GET INTUNE DEVICES (WITH PAGINATION)
# ==========================
function Get-IntuneDevices {
    Write-Log "Retrieving Intune devices..."

    $Devices = @()
    $Page = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/managedDevices"

    while ($Page) {
        $Devices += $Page.value

        if ($Page.'@odata.nextLink') {
            $Page = Invoke-MgGraphRequest -Method GET -Uri $Page.'@odata.nextLink'
        }
        else {
            $Page = $null
        }
    }

    Write-Log "Retrieved $($Devices.Count) devices"
    return $Devices
}

# ==========================
# MAIN EXECUTION
# ==========================
param(
    [string]$ExportCsvPath
)

try {
    Test-GraphModule
    Connect-GraphSafe

    $Devices = Get-IntuneDevices

    $Report = $Devices | Select-Object `
        deviceName,
        operatingSystem,
        complianceState,
        userPrincipalName,
        lastSyncDateTime,
        azureADDeviceId,
        deviceEnrollmentType

    if ($ExportCsvPath) {
        Write-Log "Exporting CSV to $ExportCsvPath"
        $Report | Export-Csv -Path $ExportCsvPath -NoTypeInformation -Encoding UTF8
        Write-Host "CSV exported to: $ExportCsvPath" -ForegroundColor Green
    }

    Write-Host "`nIntune Device Report:" -ForegroundColor Cyan
    $Report | Format-Table -AutoSize
}
catch {
    Write-Log "Fatal error: $($_.Exception.Message)" "ERROR"
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
