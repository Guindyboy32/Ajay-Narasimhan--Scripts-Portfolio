# Define variables
$softwareName = "Tier2Tickets"

# Function to check if software is installed
function Is-SoftwareInstalled {
    param (
        [string]$Name
    )
    $installed = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq $Name }
    return $installed -ne $null
}

# Function to uninstall software
function Uninstall-Software {
    param (
        [string]$Name
    )
    $software = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq $Name }
    $software.Uninstall()
}

# Check if Tier2Tickets is installed
if (Is-SoftwareInstalled -Name $softwareName) {
    Write-Host "Tier2Tickets is installed. Uninstalling..."
    Uninstall-Software -Name $softwareName
    if (-not (Is-SoftwareInstalled -Name $softwareName)) {
        Write-Host "Uninstallation completed successfully."
    } else {
        Write-Host "Uninstallation failed. Please check for any errors."
    }
} else {
    Write-Host "Tier2Tickets is not installed."
}
