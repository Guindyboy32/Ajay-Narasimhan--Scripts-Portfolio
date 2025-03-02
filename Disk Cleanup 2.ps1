# In-Depth Disk Cleanup Script for Managed Services Providers
# Remove temporary files, empty recycle bins, clear system logs, browser cache, and old Windows updates
# Function to delete temporary files
function Clear-TempFiles {
   $tempPaths = @("C:\Windows\Temp", "$env:LOCALAPPDATA\Temp", "$env:TEMP")
   foreach ($path in $tempPaths) {
       Write-Output "Clearing temporary files in $path..."
       Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
   }
}
# Function to empty recycle bins
function Empty-RecycleBin {
   $shell = New-Object -ComObject Shell.Application
   $recycleBin = $shell.Namespace(0xA)
   Write-Output "Emptying Recycle Bin..."
   $recycleBin.Items() | foreach { $_.InvokeVerb("empty") }
}
# Function to clear system logs
function Clear-SystemLogs {
   $eventLogs = Get-EventLog -List | Where-Object { $_.Entries.Count -gt 0 }
   foreach ($log in $eventLogs) {
       Write-Output "Clearing log: $($log.LogDisplayName)..."
       Clear-EventLog -LogName $log.Log
   }
}
# Function to clear browser cache for major browsers
function Clear-BrowserCache {
   $browsers = @("Google\Chrome\User Data\Default\Cache", "Microsoft\Edge\User Data\Default\Cache", "Mozilla\Firefox\Profiles")
   foreach ($browser in $browsers) {
       $cachePath = "$env:LOCALAPPDATA\$browser"
       if (Test-Path $cachePath) {
           Write-Output "Clearing browser cache in $cachePath..."
           Remove-Item "$cachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
       }
   }
}
# Function to remove old Windows update files
function Remove-OldWindowsUpdates {
   $updatesPath = "C:\Windows\SoftwareDistribution\Download"
   if (Test-Path $updatesPath) {
       Write-Output "Removing old Windows update files in $updatesPath..."
       Remove-Item "$updatesPath\*" -Recurse -Force -ErrorAction SilentlyContinue
   }
}
# Function to delete user-specific temporary files
function Clear-UserTempFiles {
   $userTempPath = "$env:USERPROFILE\AppData\Local\Temp"
   if (Test-Path $userTempPath) {
       Write-Output "Clearing user-specific temporary files in $userTempPath..."
       Remove-Item "$userTempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
   }
}
# Run the functions
Clear-TempFiles
Empty-RecycleBin
Clear-SystemLogs
Clear-BrowserCache
Remove-OldWindowsUpdates
Clear-UserTempFiles
Write-Output "In-depth disk cleanup completed successfully."