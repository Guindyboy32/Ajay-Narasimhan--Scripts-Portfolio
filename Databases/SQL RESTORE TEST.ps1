# List of remote SQL Server instances
$sqlInstances = Get-Content -Path "C:\MSP\sqlInstances.txt"
$backupPath = "\\backupserver\SQLBackups"

foreach ($instance in $sqlInstances) {
    Invoke-Command -ComputerName $instance -ScriptBlock {
        param ($backupPath)
        
        $backupFiles = Get-ChildItem -Path $backupPath -Filter "*.bak" | Sort-Object LastWriteTime -Descending
        foreach ($backupFile in $backupFiles) {
            $dbName = $backupFile.BaseName -replace "_\d{8}_\d{6}$", ""
            $query = "RESTORE DATABASE [$dbName] FROM DISK = N'$($backupFile.FullName)' WITH FILE = 1, NOUNLOAD, REPLACE, STATS = 10"
            Invoke-Sqlcmd -ServerInstance $instance -Query $query
            Write-Output "Restored database $dbName from backup $($backupFile.Name) on $instance."
        }
    } -ArgumentList $backupPath
}

# Schedule the SQL restore script to run as needed
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\MSP\BackupScripts\SQLRestore.ps1"
$trigger = New-ScheduledTaskTrigger -Once -At "2024-01-01T01:00:00"
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "OnDemandSQLRestore" -Description "Performs on-demand restoration of SQL Server databases."
