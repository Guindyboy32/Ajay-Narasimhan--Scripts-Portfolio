<#
.SYNOPSIS
Upload Windows Autopilot devices to Intune using Microsoft Graph PowerShell.

.DESCRIPTION
This script imports a CSV containing SerialNumber and HardwareHash fields,
connects to Microsoft Graph, and creates Autopilot device identities.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# Path to CSV file
$csvFile = "C:\path\to\devices.csv"

# Ensure Graph module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {
    Install-Module Microsoft.Graph.DeviceManagement -Force
}

# Connect to Graph with required permissions
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All"

# Import CSV
$deviceList = Import-Csv -Path $csvFile

foreach ($device in $deviceList) {

    Write-Host "Uploading device: $($device.SerialNumber)..."

    try {
        New-MgDeviceManagementWindowsAutopilotDeviceIdentity `
            -SerialNumber $device.SerialNumber `
            -HardwareIdentifier ([System.Convert]::FromBase64String($device.HardwareHash)) `
            -GroupTag $device.GroupTag `
            -AssignedUserPrincipalName $device.UserPrincipalName

        Write-Host "✔ Successfully uploaded $($device.SerialNumber)" -ForegroundColor Green
    }
    catch {
        Write-Host "✖ Failed to upload $($device.SerialNumber): $_" -ForegroundColor Red
    }
}
