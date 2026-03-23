# Define registry keys to be removed
$RegKeys = @(
    "HKLM:\\SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\WRUNINST",
    "HKLM:\\SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\WRUNINST",
    "HKLM:\\SOFTWARE\\WOW6432Node\\WRData",
    "HKLM:\\SOFTWARE\\WOW6432Node\\WRCore",
    "HKLM:\\SOFTWARE\\WOW6432Node\\WRMIDData",
    "HKLM:\\SOFTWARE\\WOW6432Node\\webroot",
    "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WRUNINST",
    "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\WRUNINST",
    "HKLM:\\SOFTWARE\\WRData",
    "HKLM:\\SOFTWARE\\WRMIDData",
    "HKLM:\\SOFTWARE\\WRCore",
    "HKLM:\\SOFTWARE\\webroot",
    "HKLM:\\SYSTEM\\ControlSet001\\services\\WRSVC",
    "HKLM:\\SYSTEM\\ControlSet001\\services\\WRkrn",
    "HKLM:\\SYSTEM\\ControlSet001\\services\\WRBoot",
    "HKLM:\\SYSTEM\\ControlSet001\\services\\WRCore",
    "HKLM:\\SYSTEM\\ControlSet001\\services\\WRCoreService",
    "HKLM:\\SYSTEM\\ControlSet001\\services\\wrUrlFlt",
    "HKLM:\\SYSTEM\\ControlSet002\\services\\WRSVC",
    "HKLM:\\SYSTEM\\ControlSet002\\services\\WRkrn",
    "HKLM:\\SYSTEM\\ControlSet002\\services\\WRBoot",
    "HKLM:\\SYSTEM\\ControlSet002\\services\\WRCore",
    "HKLM:\\SYSTEM\\ControlSet002\\services\\WRCoreService",
    "HKLM:\\SYSTEM\\ControlSet002\\services\\wrUrlFlt",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\WRSVC",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\WRkrn",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\WRBoot",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\WRCore",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\WRCoreService",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\wrUrlFlt"
)

# Remove registry keys
foreach ($key in $RegKeys) {
    if (Test-Path $key) {
        Remove-Item $key -Recurse -Force
    }
}

# Uninstall Webroot SecureAnywhere
Start-Process -FilePath "$env:ProgramFiles\Webroot\WRSA.exe" -ArgumentList "-uninstall" -Wait -ErrorAction SilentlyContinue

# Remove Webroot DNS Protection startup item
$RegStartupPaths = @(
    "HKLM:\\SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Run",
    "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"
)

foreach ($path in $RegStartupPaths) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
    }
}

# Remove Webroot DNS Protection folders
$Folders = @(
    "$env:ProgramData\WRData",
    "$env:ProgramData\WRCore",
    "$env:ProgramFiles\Webroot",
    "$env:ProgramFiles(x86)\Webroot",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Webroot SecureAnywhere"
)

foreach ($folder in $Folders) {
    if (Test-Path $folder) {
        Remove-Item $folder -Recurse -Force
    }
}

# Remove Webroot DNS Protection services
$Services = @(
    "WRSVC",
    "WRkrn",
    "WRBoot",
    "WRCore",
    "WRCoreService",
    "wrUrlFlt"
)

foreach ($service in $Services) {
    Get-Service -Name $service -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
    Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
}

# Remove Webroot DNS Protection tasks
$Tasks = @(
    "\Webroot SecureAnywhere",
    "\Webroot SecureAnywhere Global Scan",
    "\Webroot SecureAnywhere Instant Scan"
)

foreach ($task in $Tasks) {
    if (Test-Path "C:\Windows\System32\Tasks\$task") {
        schtasks /delete /tn $task /f
    }
}









# Stop and disable Webroot services
$services = @("WRSVC", "WRkrn", "WRBoot", "WRCore", "WRCoreService", "wrUrlFlt")

foreach ($service in $services) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

# Remove Webroot SecureAnywhere
$regKeys = @(
    "HKLM:\\SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Webroot SecureAnywhere",
    "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Webroot SecureAnywhere"
)

foreach ($key in $regKeys) {
    if (Test-Path $key) {
        Remove-Item $key -Recurse -Force
    }
}

# Uninstall Webroot SecureAnywhere using its uninstaller
$wrsaPath = "$env:ProgramFiles\Webroot\WRSA.exe"
if (Test-Path $wrsaPath) {
    Start-Process -FilePath $wrsaPath -ArgumentList "-uninstall" -Wait -ErrorAction SilentlyContinue
}

# Remove Webroot DNS Protection startup items
$regStartupPaths = @(
    "HKLM:\\SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Run",
    "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"
)

foreach ($path in $regStartupPaths) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
    }
}

# Remove Webroot DNS Protection folders
$folders = @(
    "$env:ProgramData\WRData",
    "$env:ProgramData\WRCore",
    "$env:ProgramFiles\Webroot",
    "$env:ProgramFiles(x86)\Webroot",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Webroot SecureAnywhere"
)

foreach ($folder in $folders) {
    if (Test-Path $folder) {
        Remove-Item $folder -Recurse -Force
    }
}

# Remove Webroot DNS Protection tasks
$tasks = @(
    "\Webroot SecureAnywhere",
    "\Webroot SecureAnywhere Global Scan",
    "\Webroot SecureAnywhere Instant Scan"
)

foreach ($task in $tasks) {
    schtasks /delete /tn $task /f 2>$null
}

# Remove remaining registry keys for Webroot services
$regServiceKeys = @(
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\WRSVC",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\WRkrn",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\WRBoot",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\WRCore",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\WRCoreService",
    "HKLM:\\SYSTEM\\CurrentControlSet\\services\\wrUrlFlt"
)

foreach ($key in $regServiceKeys) {
    if (Test-Path $key) {
        Remove-Item $key -Recurse -Force
    }
}
