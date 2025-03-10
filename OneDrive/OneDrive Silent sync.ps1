# Start OneDrive sync
Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
Start-Process -FilePath "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" -ArgumentList "/syncnow"
Write-Output "OneDrive sync initiated."
