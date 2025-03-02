# Specify the application names
$ztacApplicationName = "ZTAC"
$snapAgentApplicationName = "SnapAgent"

# Function to uninstall an application by name
function Uninstall-Application ($appName) {
    $identifyingNumber = (Get-WmiObject Win32_Product | Where-Object {$_.Name -eq $appName}).IdentifyingNumber
    if (-not [string]::IsNullOrEmpty($identifyingNumber)) {
        Start-Process -FilePath "MsiExec.exe" -ArgumentList "/X $identifyingNumber /quiet /qn /norestart" -Wait -ErrorAction SilentlyContinue
    } else {
        Write-Host "$appName IdentifyingNumber not found or is empty. Please check the application installation."
    }
}

# Check if the snapw process exists and stop it
if (Get-Process -Name "snapw" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "snapw" -Force -ErrorAction SilentlyContinue
    Write-Host "Stopped process: snapw"
} else {
    Write-Host "Process 'snapw' not found."
}

# Check if the snap service exists and stop it
if (Get-Process -Name "snap" -ErrorAction SilentlyContinue) {
    Stop-Service -Name "snap" -ErrorAction SilentlyContinue
    Write-Host "Stopped service: snap"
} else {
    Write-Host "Service 'snap' not found."
}

# Wait for 5 seconds
Start-Sleep -Seconds 5

# Uninstall SnapAgent
Uninstall-Application -appName $snapAgentApplicationName

# Wait for 5 seconds
Start-Sleep -Seconds 5

# Check if the ztac service exists and stop it
if (Get-Process -Name "ztac" -ErrorAction SilentlyContinue) {
    Stop-Service -Name "ztac" -ErrorAction SilentlyContinue
    Write-Host "Stopped service: ztac"
} else {
    Write-Host "Service 'ztac' not found."
}

# Wait for 5 seconds
Start-Sleep -Seconds 5

# Uninstall ZTAC
Uninstall-Application -appName $ztacApplicationName

# Wait for 5 seconds
Start-Sleep -Seconds 5

# Remove entire "C:\Program Files (x86)\Blackpoint\" directory
Remove-Item -Path "C:\Program Files (x86)\Blackpoint\" -Force -Recurse -ErrorAction SilentlyContinue

# Define an array of registry keys to delete
$registryKeys = @(
    "HKLM:\SOFTWARE\Classes\Installer\Features\0E1D3F0C2B974FA4AA0418F12B055384",
    "HKLM:\SOFTWARE\Classes\Installer\Products\0E1D3F0C2B974FA4AA0418F12B055384",
    "HKLM:\SOFTWARE\Classes\Installer\Products\0E1D3F0C2B974FA4AA0418F12B055384\SourceList",
    "HKLM:\SOFTWARE\Classes\Installer\Products\0E1D3F0C2B974FA4AA0418F12B055384\SourceList\Media",
    "HKLM:\SOFTWARE\Classes\Installer\Products\0E1D3F0C2B974FA4AA0418F12B055384\SourceList\Net",
    "HKLM:\SOFTWARE\Classes\Installer\UpgradeCodes\7CF0653F8B24F2647B3A70510A96BEE6",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\7CF0653F8B24F2647B3A70510A96BEE6",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\08C8C87010175A141912F6695F06EB95",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\5E3D36BBC4ADCA749AC6CC3774478B04",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\5E3D36BBC4ADCA749AC6CC3774478B04"
)

# Delete registry keys
foreach ($key in $registryKeys) {
    Remove-Item -Path $key -Force -ErrorAction SilentlyContinue
}
