# Define OneDrive and backup folder paths
$OneDrivePath = "$env:USERPROFILE\OneDrive"
$BackupPath = "D:\OneDriveBackup"

# Ensure the backup folder exists
if (-not (Test-Path -Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath
}

# Copy files from OneDrive to backup folder
Get-ChildItem -Path $OneDrivePath -Recurse | ForEach-Object {
    $Destination = $_.FullName -replace [regex]::Escape($OneDrivePath), $BackupPath
    if ($_.PsIsContainer) {
        New-Item -ItemType Directory -Path $Destination -Force
    } else {
        Copy-Item -Path $_.FullName -Destination $Destination -Force
    }
}

Write-Output "OneDrive files backed up successfully to $BackupPath."
