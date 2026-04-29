<#
.SYNOPSIS
    Monitors disk space on remote machines and sends alerts when thresholds are exceeded.

.DESCRIPTION
    - Validates machine reachability
    - Queries disk space using CIM (modern WMI)
    - Sends email alerts for low disk space
    - Logs all actions with timestamps
    - Provides summary reporting
    - Uses safe error handling

.NOTES
    Author: Ajay Narasimhan
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MachinesFile = "C:\MSP\machines.txt",

    [Parameter(Mandatory = $true)]
    [string]$LogPath = "C:\MSP\DiskAlerts",

    [Parameter(Mandatory = $true)]
    [int]$ThresholdGB = 10,

    [Parameter(Mandatory = $true)]
    [string]$SmtpServer = "smtp.example.com",

    [Parameter(Mandatory = $true)]
    [string]$From = "alerts@example.com",

    [Parameter(Mandatory = $true)]
    [string]$To = "admin@example.com"
)

# -----------------------------
# Helper Functions
# -----------------------------

function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp  $Message" | Out-File -FilePath $Global:LogFile -Append
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Test-RemoteMachine {
    param([string]$Machine)

    if (-not (Test-Connection -ComputerName $Machine -Count 1 -Quiet)) {
        return $false
    }
    return $true
}

function Send-DiskAlert {
    param(
        [string]$Machine,
        [string]$Drive,
        [decimal]$FreeGB
    )

    $subject = "Disk Space Alert on $Machine"
    $body = @"
Warning: Low disk space detected.

Machine: $Machine
Drive:   $Drive
Free:    $FreeGB GB
Threshold: $ThresholdGB GB

Immediate attention recommended.
"@

    try {
        Send-MailMessage -SmtpServer $SmtpServer -From $From -To $To -Subject $subject -Body $body
        Write-Log "Email alert sent for $Machine ($Drive - $FreeGB GB)"
    }
    catch {
        Write-Log "ERROR sending email alert for $Machine: $_"
    }
}

# -----------------------------
# Initialization
# -----------------------------

Ensure-Directory -Path $LogPath
$Global:LogFile = Join-Path $LogPath ("DiskAlert_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt")

Write-Log "Starting disk space monitoring..."

if (-not (Test-Path $MachinesFile)) {
    Write-Host "ERROR: Machines file not found: $MachinesFile" -ForegroundColor Red
    exit 1
}

$machines = Get-Content -Path $MachinesFile | Where-Object { $_ -and $_.Trim() -ne "" }
$summary = @()

# -----------------------------
# Monitoring Loop
# -----------------------------

foreach ($machine in $machines) {

    Write-Log "Checking machine: $machine"

    if (-not (Test-RemoteMachine -Machine $machine)) {
        Write-Log "ERROR: Machine unreachable"
        $summary += "$machine - FAILED (unreachable)"
        continue
    }

    try {
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $machine -Filter "DriveType=3"

        foreach ($disk in $disks) {
            $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)

            if ($freeGB -lt $ThresholdGB) {
                Write-Log "ALERT: $machine $($disk.DeviceID) has $freeGB GB free"
                Send-DiskAlert -Machine $machine -Drive $disk.DeviceID -FreeGB $freeGB
                $summary += "$machine - ALERT ($($disk.DeviceID): $freeGB GB)"
            }
        }
    }
    catch {
        Write-Log "ERROR retrieving disk info: $_"
        $summary += "$machine - FAILED (query error)"
    }
}

# -----------------------------
# Summary Output
# -----------------------------

Write-Host "`nDisk Space Monitoring Summary:" -ForegroundColor Cyan
$summary | ForEach-Object { Write-Host $_ }

Write-Log "Disk space monitoring completed."
