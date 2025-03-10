# Define OneDrive folder path
$OneDrivePath = "$env:USERPROFILE\OneDrive"

# Specify the retention period (e.g., 30 days)
$RetentionPeriod = (Get-Date).AddDays(-30)

# Delete files older than retention period
Get-ChildItem -Path $OneDrivePath -Recurse -File | Where-Object { $_.LastWriteTime -lt $RetentionPeriod } | Remove-Item -Force

Write-Output "Old files in OneDrive cleaned up successfully."
