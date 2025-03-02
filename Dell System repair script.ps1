# Dell System Repair Script
# This script triggers Dell System Repair (SupportAssist OS Recovery) silently
# Check if SupportAssist OS Recovery is installed
$SupportAssistPath = "C:\Program Files\Dell\SupportAssistOSRecovery\"
if (Test-Path $SupportAssistPath) {
   Write-Output "SupportAssist OS Recovery found. Initiating system repair..."
   Start-Process -FilePath "$SupportAssistPath\SupportAssistOSRecovery.exe" -ArgumentList "/silent" -Wait
   Write-Output "System repair initiated successfully."
} else {
   Write-Output "SupportAssist OS Recovery not found. Please ensure it is installed on the system."
}