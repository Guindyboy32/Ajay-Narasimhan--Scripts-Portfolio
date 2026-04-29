<#
.SYNOPSIS
    Performs full SQL database backups on remote SQL Server instances.

.DESCRIPTION
    - Validates SQL instance reachability
    - Backs up all user databases (excludes system DBs)
    - Stores backups in a central UNC path
    - Logs all actions per instance
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
    [string]$LogPath = "C:\MSP\SQLBackupLogs",

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
# Backup Loop
# -----------------------------

foreach ($instance in $instances) {

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = Join-Path $LogPath "SQLBackup_${instance}_$timestamp.txt"

    Write-Host "Processing SQL instance: $instance" -ForegroundColor Cyan
    Write-Log "Starting backup for $instance" $logFile

    if (-not (Test-SqlConnection -Instance $instance)) {
        Write-Host "SQL instance unreachable: $instance" -ForegroundColor Yellow
        Write-Log "ERROR: SQL instance unreachable" $logFile
        $summary += "$instance - FAILED (unreachable)"
        continue
    }

    try {
        $dbQuery = @"
SELECT name 
FROM sys.databases 
WHERE name NOT IN ('master','model','msdb','tempdb')
AND state = 0
"@

        $databases = Invoke-Sqlcmd -ServerInstance $instance -Query $dbQuery -ErrorAction Stop

        foreach ($db in $databases) {
            $dbName = $db.name
            $backupFile = Join-Path $BackupPath "$instance`_$dbName`_$(Get-Date -Format 'yyyyMMdd_HHmmss').bak"

            $backupQuery = @"
BACKUP DATABASE [$dbName]
TO DISK = N'$backupFile'
WITH NOFORMAT, NOINIT,
NAME = N'$dbName - Full Backup',
SKIP, NOREWIND, NOUNLOAD, STATS = 10;
"@

            Write-Log "Backing up database: $dbName" $logFile
            Invoke-Sqlcmd -ServerInstance $instance -Query $backupQuery -ErrorAction Stop
            Write-Log "Backup completed for $dbName" $logFile
        }

        Write-Host "Backup completed for $instance" -ForegroundColor Green
        Write-Log "Backup completed successfully" $logFile
        $summary += "$instance - SUCCESS"
    }
    catch {
        Write-Host "Backup failed for $instance" -ForegroundColor Red
        Write-Log "ERROR: $_" $logFile
        $summary += "$instance - FAILED (error)"
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
    $trigger = New-ScheduledTaskTrigger -Daily -At 1am

    Register-ScheduledTask -Action $action -Trigger $trigger `
        -TaskName "DailySQLBackup" `
        -Description "Performs daily SQL Server backups."

    Write-Host "Scheduled task created: DailySQLBackup" -ForegroundColor Green
}
