This folder contains a set of PowerShell automation scripts designed to simplify and standardize SQL Server backup and restore operations across multiple remote SQL instances. These scripts are built for MSPs, DBAs, and enterprise IT teams who require reliable, repeatable, and auditable SQL maintenance workflows.
Each script follows senior‑level engineering practices, including validation, logging, error handling, and predictable behavior.

1. SQL Backup Script
File: SQLBackup.ps1
Purpose: Performs full backups of all user databases across multiple SQL Server instances.

What It Does
- Reads SQL instance names from a text file
- Validates SQL connectivity before running any backup
- Backs up only user databases (system DBs excluded)
- Stores backups in a centralized UNC path
- Creates per‑instance log files with timestamps
- Provides a clear success/failure summary
- Optional: registers a scheduled task for daily backups

Example Output Structure
\\backupserver\SQLBackups\
    SQLSERVER01_DB1_20240101_010000.bak
    SQLSERVER01_DB2_20240101_010000.bak


When to Use
Use this script when you need consistent, automated SQL backups across multiple servers without relying on SQL Agent jobs or third‑party tools.

2. SQL Restore Script
File: SQLRestore.ps1
Purpose: Restores SQL databases from the latest available backup for each database.

What It Does
- Validates SQL instance connectivity
- Identifies the most recent .bak file per database
- Restores only user databases
- Uses REPLACE to safely overwrite existing DBs
- Logs all restore actions with timestamps
- Provides a summary of success/failure
- Optional: registers a scheduled task for on‑demand restore operations

Safety Features
- Ensures backups match the correct instance + database
- Prevents accidental restores from outdated files
- Skips databases with no available backup

When to Use
Use this script for disaster recovery, test environment refreshes, or automated restore workflows.

3. SQL Backup + Restore Automation Suite
Together, these scripts form a complete SQL maintenance toolkit:

Backup + Restore Workflow
- SQLBackup.ps1
- Runs nightly
- Creates timestamped .bak files
- Logs all backup activity
- SQLRestore.ps1
- Restores the latest backup per database
- Useful for DR, QA refreshes, or automated testing

Shared Engineering Standards

All scripts include:
- Parameterized configuration
- Validation of SQL connectivity
- Structured logging
- Error handling with try/catch
- Summary reporting
- Predictable, idempotent behavior
- Optional scheduled task creation

Requirements

- PowerShell 5.1 or PowerShell 7.x
- SQL Server PowerShell module (SqlServer)
- Windows authentication or SQL authentication with backup/restore rights
- Network share with write access
- Text file containing SQL instance names

Example sqlInstances.txt
SQLSERVER01
SQLSERVER02\INSTANCE1
SQLSERVER03

Example Usage
Run Backup
.\SQLBackup.ps1 `
    -InstancesFile "C:\MSP\sqlInstances.txt" `
    -BackupPath "\\backupserver\SQLBackups" `
    -LogPath "C:\MSP\SQLBackupLogs" `
    -RegisterScheduledTask


Run Restore
.\SQLRestore.ps1 `
    -InstancesFile "C:\MSP\sqlInstances.txt" `
    -BackupPath "\\backupserver\SQLBackups" `
    -LogPath "C:\MSP\SQLRestoreLogs"



Notes & Best Practices
- Always test restore operations in a non‑production environment
- Ensure backup storage has sufficient capacity
- Use retention policies to clean up old .bak files
- Secure the backup share with proper ACLs
- Consider encrypting backups for sensitive environments
