# Get the MSP360 Backup application object
$msp360 = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "MSP360*Backup*"}

# Check if MSP360 Backup is installed
if ($msp360) {
    # Uninstall MSP360 Backup
    $msp360.Uninstall()
    Write-Host "MSP360 Backup is being uninstalled..." -ForegroundColor Green
} else {
    Write-Host "MSP360 Backup is not installed." -ForegroundColor Yellow
}