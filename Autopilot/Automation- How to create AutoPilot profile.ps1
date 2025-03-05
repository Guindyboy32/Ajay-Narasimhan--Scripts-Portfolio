# This scripts connects to Microsoft Graph.  
# I will explain this further, you will need to have permissions needed to manage AutoPilot profiles. 

# Connect to Microsoft Graph
Install-Module -Name Microsoft.Graph -Force
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"

# Create AutoPilot Profile
$params = @{
    displayName          = "Standard Deployment"
    description          = "Deployment profile for standard users."
    enrollmentStatusPage = @{
        isConfigured = $true
    }
    language             = "en-US"
    outOfBoxExperience   = @{
        hideEscapeOption        = $true
        hideEULA                = $true
        userType                = "Standard"
    }
}

New-MgDeviceManagementDeploymentProfile -BodyParameter $params
