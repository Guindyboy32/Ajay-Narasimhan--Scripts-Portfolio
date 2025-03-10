# Define OneDrive path and folders to redirect
$OneDrivePath = "$env:USERPROFILE\OneDrive"
$FoldersToRedirect = @("Desktop", "Documents", "Pictures", "Downloads")

foreach ($Folder in $FoldersToRedirect) {
    $CurrentPath = Join-Path $env:USERPROFILE $Folder
    $NewPath = Join-Path $OneDrivePath $Folder

    if (-not (Test-Path -Path $NewPath)) {
        New-Item -ItemType Directory -Path $NewPath
    }

    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $Folder -Value $NewPath -Force
}
Write-Output "Selected folders redirected to OneDrive."
