<#
.SYNOPSIS
Create a Windows Autopilot Enrollment Status Page (ESP) profile using Microsoft Graph.

.DESCRIPTION
This script builds a JSON body for an ESP profile and submits it to the
Microsoft Graph API using Invoke-MgGraphRequest.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# ESP configuration
$ESPConfig = @{
    displayName = "Default ESP"
    description = "Standard Enrollment Status Page for Autopilot deployments"
    priority = 1
    showInstallationProgress = $true
    blockDeviceUseUntilProfileApplied = $true
    allowDeviceResetOnInstallFailure = $true
    allowLogCollectionOnInstallFailure = $true
    enableCustomMessages = $true
    customMessage = "Your device is being configured. Please wait..."
}

# Convert to JSON
$BodyJson = $ESPConfig | ConvertTo-Json -Depth 5

# Create ESP profile
Invoke-MgGraphRequest `
    -Uri "https://graph.microsoft.com/v1.0/deviceManagement/enrollmentStatusPages" `
    -Method POST `
    -Body $BodyJson `
    -ContentType "application/json"
