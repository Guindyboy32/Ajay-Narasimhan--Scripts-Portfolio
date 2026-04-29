<#
.SYNOPSIS
    Restores SQL Server databases from the latest backup files.

.DESCRIPTION
    - Validates SQL instance connectivity
    - Identifies the latest .bak file per database
    - Restores only user databases (system DBs excluded)
    - Logs all actions with timestamps
    - Includes error handling and summary reporting
    - Optional scheduled task creation

.NOTES
    Author: Ajay Narasimhan
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InstancesFile = "C:\MSP\sqlInstances.txt",

    [Parameter(Mandatory = $true)]
    [string]$BackupPath = "\\backupserver\SQLBackups",

    [Parameter(Mandatory = $true)]
    [string]$LogPath = "C:\MSP\SQLRestoreLogs",

    [switch]$RegisterScheduledTask
)

# -----------------------------
# Helper Functions
# -----------------------------

function Write-Log {
    param([string]$Message, [string]$LogFile)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp  $Message" | Out-File -FilePath $LogFile -Append
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Test-SqlConnection {
    param([string]$Instance)

    try {
        Invoke-Sqlcmd -ServerInstance $Instance -Query "SELECT 1" -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# -----------------------------
# Initialization
# -----------------------------

Ensure-Directory -Path $LogPath

if (-not (Test-Path -Path $InstancesFile)) {
    Write-Host "ERROR: SQL instances file not found: $InstancesFile" -ForegroundColor Red
    exit 1
}

$instances = Get-Content -Path $InstancesFile | Where-Object { $_ -and $_.Trim() -ne "" }
$summary = @()

# -----------------------------
# Restore Loop
# -----------------------------

foreach ($instance in $instances) {

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = Join-Path $LogPath "SQLRestore_${instance}_$timestamp.txt"

    Write-Host "Processing SQL instance: $instance" -ForegroundColor Cyan
    Write-Log "Starting restore for $instance" $logFile

    if (-not (Test-SqlConnection -Instance $instance)) {
        Write-Host "SQL instance unreachable: $instance" -ForegroundColor Yellow
        Write-Log "ERROR: SQL instance unreachable" $logFile
        $summary += "$instance - FAILED (unreachable)"
        continue
    }

    try {
        # Get list of user databases
        $dbQuery = @"
SELECT name 
FROM sys.databases 
WHERE name NOT IN ('master','model','msdb','tempdb')
"@

        $databases = Invoke-Sqlcmd -ServerInstance $instance -Query $dbQuery -ErrorAction Stop

        foreach ($db in $databases) {
            $dbName = $db.name

            # Find latest backup file for this DB
            $pattern = "${instance}_${dbName}_*.bak"
            $latestBackup = Get-ChildItem -Path $BackupPath -Filter $pattern |
                            Sort-Object LastWriteTime -Descending |
                            Select-Object -First 1

            if (-not $latestBackup) {
                Write-Log "No backup found for $dbName" $logFile
                continue
            }

            Write-Log "Restoring $dbName from $($latestBackup.Name)" $logFile

            $restoreQuery = @"
RESTORE DATABASE [$dbName]
FROM DISK = N'$($latestBackup.FullName)'
WITH FILE = 1, REPLACE, STATS = 10;
"@

            Invoke-Sqlcmd -ServerInstance $instance -Query $restoreQuery -ErrorAction Stop

            Write-Log "Restore completed for $dbName" $logFile
        }

        Write-Host "Restore completed for $instance" -ForegroundColor Green
        Write-Log "Restore completed successfully" $logFile
        $summary += "$instance - SUCCESS"
    }
    catch {
        Write-Host "Restore failed for $instance" -ForegroundColor Red
        Write-Log "ERROR: $_" $logFile
        $summary += "$instance - FAILED (error)"
    }
}

# -----------------------------
# Summary Output
# -----------------------------

Write-Host "`nRestore Summary:" -ForegroundColor Cyan
$summary | ForEach-Object { Write-Host $_ }

# -----------------------------
# Optional Scheduled Task
# -----------------------------

if ($RegisterScheduledTask) {
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$PSCommandPath`""
    $trigger = New-ScheduledTaskTrigger -Once -At "2024-01-01T01:00:00"

    Register-ScheduledTask -Action $action -Trigger $trigger `
        -TaskName "OnDemandSQLRestore" `
        -Description "Performs on-demand SQL database restoration."

    Write-Host "Scheduled task created: OnDemandSQLRestore" -ForegroundColor Green
}
