# PowerShell script to uninstall Zoho Assist
$packageName = 'Zoho Assist'
$installerType = 'msi'
$silentArgs = '/quiet /norestart'
$uninstallString = (Get-WmiObject -Query "SELECT UninstallString FROM Win32_Product WHERE Name = '$packageName'").UninstallString

if ($uninstallString) {
    Start-Process "msiexec.exe" -ArgumentList "$uninstallString $silentArgs" -Wait
    Write-Output "Zoho Assist has been uninstalled successfully."
} else {
    Write-Output "Zoho Assist is not installed."
}




# PowerShell script to uninstall Zoho Assist
$packageName = 'Zoho Assist'
$uninstallPath = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -eq $packageName }).UninstallString

if ($uninstallPath) {
    Start-Process "msiexec.exe" -ArgumentList "/x $uninstallPath /quiet /norestart" -Wait
    Write-Output "Zoho Assist has been uninstalled successfully."
} else {
    Write-Output "Zoho Assist is not installed."
}



# Define the path to the installer
$installerPath = "C:\Program Files (x86)\ZohoMeeting\Connect.exe"
# Define the silent install arguments
$silentArgs = "/S"
# Run the installer with silent arguments
Start-Process -FilePath $installerPath -ArgumentList $silentArgs -Wait -NoNewWindow


# Path to the Zoho Assist installation directory
$zohoAssistPath = "C:\Program Files (x86)\ZohoMeeting\Connect.exe"

# Path to the uninstaller executable
$uninstallerPath = "$zohoAssistPath\Connect.exe" # The executable used in the uninstall command

# Check if the uninstaller exists
if (Test-Path $uninstallerPath) {
    # Run the uninstaller silently with the -UnInstall argument
    Start-Process -FilePath $uninstallerPath -ArgumentList "-UnInstall ASSIST" -Wait -NoNewWindow
    Write-Output "Zoho Assist has been uninstalled successfully."
} else {
    Write-Output "Uninstaller not found. Please check the installation path."
}
