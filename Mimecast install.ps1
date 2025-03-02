# Define the path to the Mimecast Outlook add-on installer
$installerPath = "Mimecast for outlook 7.10.1.133 (x64).msi"

# Check if Outlook is already running and close it if necessary
$outlookProcess = Get-Process "OUTLOOK" -ErrorAction SilentlyContinue
if ($outlookProcess) {
    Write-Output "Closing Outlook..."
    $outlookProcess | ForEach-Object { $_.CloseMainWindow() | Out-Null }
    $outlookProcess | Wait-Process
}

# Install the Mimecast add-on using the installer
Write-Output "Installing Mimecast Outlook add-on..."
Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet" -Wait

# Print back completion.
Write-Output "The install is (allegedly) complete."