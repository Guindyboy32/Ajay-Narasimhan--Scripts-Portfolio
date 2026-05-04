<#
.SYNOPSIS
Enables and validates Azure AD Connect Health components on a server.

.DESCRIPTION
This script loads the Azure AD Connect Health module, enables the service,
registers the Sync Agent, and performs basic health and connectivity checks.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# ---------------------------------------------
# Load Module
# ---------------------------------------------
try {
    Import-Module AzureADConnectHealth -ErrorAction Stop
}
catch {
    Write-Host "ERROR: AzureADConnectHealth module not found. Install the Azure AD Connect Health agent first." -ForegroundColor Red
    return
}

# ---------------------------------------------
# Enable Azure AD Connect Health
# ---------------------------------------------
try {
    Enable-AzureADConnectHealth
    Write-Host "✔ Azure AD Connect Health enabled."
}
catch {
    Write-Host "✖ Failed to enable Azure AD Connect Health. $($_.Exception.Message)" -ForegroundColor Red
}

# ---------------------------------------------
# Check Current Health Status
# ---------------------------------------------
try {
    $status = Get-AzureADConnectHealthStatus
    Write-Host "✔ Current Health Status:"
    $status
}
catch {
    Write-Host "✖ Unable to retrieve health status. $($_.Exception.Message)" -ForegroundColor Red
}

# ---------------------------------------------
# Register Sync Agent
# ---------------------------------------------
try {
    Register-AzureADConnectHealthSyncAgent
    Write-Host "✔ Sync Agent registered successfully."
}
catch {
    Write-Host "✖ Failed to register Sync Agent. $($_.Exception.Message)" -ForegroundColor Red
}

# ---------------------------------------------
# Test Connectivity
# ---------------------------------------------
try {
    $connectivity = Test-AzureADConnectHealthConnectivity
    Write-Host "✔ Connectivity Test Results:"
    $connectivity
}
catch {
    Write-Host "✖ Connectivity test failed. $($_.Exception.Message)" -ForegroundColor Red
}
