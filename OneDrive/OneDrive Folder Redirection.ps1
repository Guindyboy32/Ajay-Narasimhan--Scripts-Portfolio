# Define the OneDrive folder path
$OneDrivePath = "$env:USERPROFILE\OneDrive"

# List of known folders to redirect, including Downloads
$FoldersToRedirect = @("Desktop", "Documents", "Pictures", "Downloads")

foreach ($Folder in $FoldersToRedirect) {
    # Get the current folder path
    $CurrentPath = Join-Path -Path $env:USERPROFILE -ChildPath $Folder

    # Define the new OneDrive path for the folder
    $NewPath = Join-Path -Path $OneDrivePath -ChildPath $Folder

    # Check if the folder exists in OneDrive, if not, create it
    if (-not (Test-Path -Path $NewPath)) {
        New-Item -ItemType Directory -Path $NewPath
    }

    # Redirect the folder to OneDrive
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $Folder -Value $NewPath -Force
}

Write-Output "Folders (including Downloads) have been redirected to OneDrive successfully."
