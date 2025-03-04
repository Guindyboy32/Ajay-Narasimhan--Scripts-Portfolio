# Define variables
$profileName = "YourProfileName"  # Replace with your Outlook profile name
$backupFolder = "C:\Temp\OutlookBackup"  # Folder to save the OST backup

# Create the backup folder if it doesn't exist
if (-not (Test-Path -Path $backupFolder)) {
    New-Item -ItemType Directory -Path $backupFolder
}

# Save the OST file to the backup folder
$profilePath = "C:\Users\$env:USERNAME\AppData\Local\Microsoft\Outlook"
$ostFiles = Get-ChildItem -Path $profilePath -Filter "*.ost"
foreach ($ostFile in $ostFiles) {
    Copy-Item -Path $ostFile.FullName -Destination $backupFolder
}

# Delete the Outlook profile
$regPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles\$profileName"
Remove-Item -Path $regPath -Recurse -Force

# Create a new Outlook profile (this part can be manual depending on your specific requirements)
# You'll need to configure the new profile manually or use an additional script or tool to automate this process

Write-Output "Outlook profile '$profileName' deleted and OST files backed up to '$backupFolder'."
