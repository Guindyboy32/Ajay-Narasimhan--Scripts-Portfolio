# Define backup paths and list of machines
$sourcePath = "C:\ClientData"
$backupPath = "\\backupserver\ClientBackups"
$logPath = "C:\MSP\BackupLogs"
$machines = Get-Content -Path "C:\MSP\machines.txt"

# Ensure log directory exists
if (-not (Test-Path -Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath
}

foreach ($machine in $machines) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile = "$logPath\BackupLog_$machine_$timestamp.txt"

    Invoke-Command -ComputerName $machine -ScriptBlock {
        param ($sourcePath, $backupPath, $logFile)
        $date = Get-Date -Format "yyyyMMdd"
        $destinationPath = "$backupPath\$env:COMPUTERNAME\$date"

        # Create the destination directory if it doesn't exist
        if (-not (Test-Path -Path $destinationPath)) {
            New-Item -ItemType Directory -Path $destinationPath
        }

        # Perform incremental backup and log the activity
        Robocopy $sourcePath $destinationPath /MIR /LOG:$logFile /NFL /NDL
        Write-Output "Incremental backup completed for $env:COMPUTERNAME." | Out-File -FilePath $logFile -Append
    } -ArgumentList $sourcePath, $backupPath, $logFile

    Write-Output "Incremental backup and logging completed for $machine."
}

# Schedule the backup script to run nightly
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\MSP\BackupScripts\IncrementalBackup.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 2am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "NightlyIncrementalBackup" -Description "Performs nightly incremental backups and logs activity."
