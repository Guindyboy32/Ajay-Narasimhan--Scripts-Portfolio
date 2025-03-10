# Define backup and OneDrive folder paths
$BackupPath = "D:\OneDriveBackup"
$OneDrivePath = "$env:USERPROFILE\OneDrive"

# Copy files from backup to OneDrive
Get-ChildItem -Path $BackupPath -Recurse | ForEach-Object {
    $Destination = $_.FullName -replace [regex]::Escape($BackupPath), $OneDrivePath
    if ($_.PsIsContainer) {
        New-Item -ItemType Directory -Path $Destination -Force
    } else {
        Copy-Item -Path $_.FullName -Destination $Destination -Force
    }
}

Write-Output "Backup files restored to OneDrive successfully."
