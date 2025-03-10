# Check for OneDrive process
$OneDriveProcess = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue

if ($OneDriveProcess) {
    Write-Output "OneDrive is running."
} else {
    Write-Output "OneDrive is not running. Please start OneDrive."
}
