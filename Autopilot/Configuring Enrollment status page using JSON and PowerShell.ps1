# Sample JSON body for the API
$ESPConfig = @{
    displayName = "Default ESP"
    enableCustomMessages = $true
    customMessage = "Your device is being configured. Please wait..."
    blockDeviceUseUntilProfileApplied = $true
}

# Call Microsoft Graph API to set ESP
Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/enrollmentStatusPages" -Method POST -Body $ESPConfig
