<#
.SYNOPSIS
Upload Windows Autopilot devices to Intune using Microsoft Graph PowerShell.

.DESCRIPTION
This script imports a CSV containing SerialNumber, HardwareHash, and optional
GroupTag/UserPrincipalName fields. It connects to Microsoft Graph and creates
Autopilot device identities using the supported Graph API.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# Path to CSV file
$csvFile = "C:\path\to\devices.csv"

# Validate CSV exists
if (-not (Test-Path $csvFile)) {
    Write-Host "CSV file not found at: $csvFile" -ForegroundColor Red
    exit 1
}

# Ensure Graph module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {
    Write-Host "Installing Microsoft.Graph.DeviceManagement module..."
    Install-Module Microsoft.Graph.DeviceManagement -Force
}

# Connect to Graph with required permissions
Write-Host "Connecting to Microsoft Graph..."
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
        Write-Host "✖ Failed to upload $($device.SerialNumber)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkYellow
    }
}
