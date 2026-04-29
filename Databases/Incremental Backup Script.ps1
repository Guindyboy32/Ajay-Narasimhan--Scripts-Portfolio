<#
.SYNOPSIS
    Performs incremental backups from remote machines to a central backup share.

.DESCRIPTION
    - Validates machine reachability and remoting
    - Performs incremental backups using Robocopy
    - Creates per‑machine, per‑day backup folders
    - Logs all actions with timestamps
    - Provides error handling and summary reporting
    - Optional scheduled task creation

.NOTES
    Author: Ajay Narasimhan
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath = "C:\ClientData",

    [Parameter(Mandatory = $true)]
    [string]$BackupPath = "\\backupserver\ClientBackups",

    [Parameter(Mandatory = $true)]
    [string]$MachinesFile = "C:\MSP\machines.txt",

    [Parameter(Mandatory = $true)]
    [string]$LogPath = "C:\MSP\BackupLogs",

    [switch]$RegisterScheduledTask
)

# -----------------------------
# Helper Functions
# -----------------------------

function Write-Log {
    param(
        [string]$Message,
        [string]$LogFile
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp  $Message" | Out-File -FilePath $LogFile -Append
}

function Test-RemoteMachine {
    param([string]$Machine)

    if (-not (Test-Connection -ComputerName $Machine -Count 1 -Quiet)) {
        return $false
    }
    return $true
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# -----------------------------
# Initialization
# -----------------------------

Ensure-Directory -Path $LogPath

if (-not (Test-Path -Path $MachinesFile)) {
    Write-Host "ERROR: Machines file not found: $MachinesFile" -ForegroundColor Red
    exit 1
}

$machines = Get-Content -Path $MachinesFile | Where-Object { $_ -and $_.Trim() -ne "" }

$summary = @()

# -----------------------------
# Backup Loop
# -----------------------------

foreach ($machine in $machines) {

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = Join-Path $LogPath "BackupLog_${machine}_$timestamp.txt"

    Write-Host "Processing $machine..." -ForegroundColor Cyan
    Write-Log "Starting backup for $machine" $logFile

    if (-not (Test-RemoteMachine -Machine $machine)) {
        Write-Host "Machine unreachable: $machine" -ForegroundColor Yellow
        Write-Log "ERROR: Machine unreachable" $logFile
        $summary += "$machine - FAILED (unreachable)"
        continue
    }

    try {
        Invoke-Command -ComputerName $machine -ScriptBlock {
            param ($SourcePath, $BackupPath, $LogFile)

            $date = Get-Date -Format "yyyyMMdd"
            $destinationPath = Join-Path $BackupPath "$env:COMPUTERNAME\$date"

            if (-not (Test-Path -Path $destinationPath)) {
                New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
            }

            Robocopy $SourcePath $destinationPath /MIR /NFL /NDL /LOG:$LogFile

            "Backup completed successfully for $env:COMPUTERNAME" | Out-File -FilePath $LogFile -Append

        } -ArgumentList $SourcePath, $BackupPath, $logFile -ErrorAction Stop

        Write-Host "Backup completed for $machine" -ForegroundColor Green
        Write-Log "Backup completed successfully" $logFile
        $summary += "$machine - SUCCESS"

    }
    catch {
        Write-Host "Backup failed for $machine" -ForegroundColor Red
        Write-Log "ERROR: $_" $logFile
        $summary += "$machine - FAILED (error)"
    }
}

# -----------------------------
# Summary Output
# -----------------------------

Write-Host "`nBackup Summary:" -ForegroundColor Cyan
$summary | ForEach-Object { Write-Host $_ }

# -----------------------------
# Optional Scheduled Task
# -----------------------------

if ($RegisterScheduledTask) {
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$PSCommandPath`""
    $trigger = New-ScheduledTaskTrigger -Daily -At 2am

    Register-ScheduledTask -Action $action -Trigger $trigger `
        -TaskName "NightlyIncrementalBackup" `
        -Description "Performs nightly incremental backups and logs activity."

    Write-Host "Scheduled task created: NightlyIncrementalBackup" -ForegroundColor Green
}
