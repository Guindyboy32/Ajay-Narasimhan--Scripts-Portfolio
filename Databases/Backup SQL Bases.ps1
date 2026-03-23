# List of remote SQL Server instances
$sqlInstances = Get-Content -Path "C:\MSP\sqlInstances.txt"
$backupPath = "\\backupserver\SQLBackups"

foreach ($instance in $sqlInstances) {
    Invoke-Command -ComputerName $instance -ScriptBlock {
        param ($backupPath)
        
        $databases = Invoke-Sqlcmd -ServerInstance $instance -Query "SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')"
        foreach ($db in $databases) {
            $backupFile = "$backupPath\$($db.name)_$((Get-Date).ToString('yyyyMMdd_HHmmss')).bak"
            $query = "BACKUP DATABASE [$($db.name)] TO DISK = N'$backupFile' WITH NOFORMAT, NOINIT, NAME = N'$($db.name) - Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
            Invoke-Sqlcmd -ServerInstance $instance -Query $query
            Write-Output "Backup completed for database $($db.name) on $instance."
        }
    } -ArgumentList $backupPath
}

# Schedule the SQL backup script to run daily
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\MSP\BackupScripts\SQLBackup.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 1am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DailySQLBackup" -Description "Performs daily backups of SQL Server databases."
