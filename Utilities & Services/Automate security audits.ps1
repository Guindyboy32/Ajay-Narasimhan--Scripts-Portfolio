<#
.SYNOPSIS
Performs a remote security audit on multiple Windows machines and generates
timestamped reports including firewall, antivirus, and update status.

.DESCRIPTION
Reads a list of machine names, runs remote security diagnostics, and stores
reports locally. Includes error handling, directory validation, and clean
output formatting.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# ---------------------------------------------
# Configuration
# ---------------------------------------------
$MachineListPath = "C:\MSP\machines.txt"
$ReportPath      = "C:\MSP\SecurityAuditReports"

# Ensure report directory exists
if (-not (Test-Path $ReportPath)) {
    New-Item -Path $ReportPath -ItemType Directory -Force | Out-Null
}

# Load machine list
if (-not (Test-Path $MachineListPath)) {
    Write-Host "ERROR: Machine list not found at $MachineListPath"
    exit 1
}

$Machines = Get-Content -Path $MachineListPath

# ---------------------------------------------
# Remote Execution
# ---------------------------------------------
foreach ($Machine in $Machines) {

    Write-Host "Auditing $Machine..."

    try {
        Invoke-Command -ComputerName $Machine -ErrorAction Stop -ScriptBlock {
            param($ReportPath)

            $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
            $reportFile = Join-Path $ReportPath "$env:COMPUTERNAME-SecurityAudit-$timestamp.txt"

            # Collect firewall status
            $firewallStatus = Get-NetFirewallProfile -Profile Domain,Public,Private |
                Select-Object Name, Enabled

            # Collect antivirus status (Defender)
            $avStatus = Get-MpComputerStatus |
                Select-Object AMRunningMode, AntispywareEnabled, AntivirusEnabled, RealTimeProtectionEnabled

            # Collect Windows Update summary
            $updateSummary = Get-WindowsUpdate -ErrorAction SilentlyContinue |
                Select-Object KB, Title, IsDownloaded, IsInstalled, LastScanTime

            # Build report
            $report = @()
            $report += "===== SECURITY AUDIT REPORT ====="
            $report += "Computer: $env:COMPUTERNAME"
            $report += "Generated: $(Get-Date)"
            $report += ""
            $report += "---- Firewall Status ----"
            $report += ($firewallStatus | Out-String)
            $report += "---- Antivirus Status ----"
            $report += ($avStatus | Out-String)
            $report += "---- Windows Update Summary ----"
            $report += ($updateSummary | Out-String)

            # Write report
            $report | Out-File -FilePath $reportFile -Encoding UTF8

            Write-Output "Report generated: $reportFile"
        } -ArgumentList $ReportPath
    }
    catch {
        Write-Host "ERROR: Unable to audit $Machine. $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ---------------------------------------------
# Optional: Register Scheduled Task
# ---------------------------------------------
$action  = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\MSP\AuditScripts\SecurityAudit.ps1"
$trigger = New-ScheduledTaskTrigger -Once -At "2024-01-01T00:00:00" -RepeatEvery "90 days"

Register-ScheduledTask -Action $action `
                       -Trigger $trigger `
                       -TaskName "QuarterlySecurityAudit" `
                       -Description "Performs quarterly security audits."
