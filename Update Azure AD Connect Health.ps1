# Import the AzureADConnectHealth module
Import-Module AzureADConnectHealth

# Enable Azure AD Connect Health
Enable-AzureADConnectHealth

# Check the current status of Azure AD Connect Health
Get-AzureADConnectHealthStatus

# Register the Azure AD Connect Health Sync Agent
Register-AzureADConnectHealthSyncAgent

# Test the connectivity to Azure AD Connect Health
Test-AzureADConnectHealthConnectivity
