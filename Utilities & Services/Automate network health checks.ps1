<#
.SYNOPSIS
Collects network health information from remote machines and generates
per‑device reports. Designed for MSP or enterprise fleet monitoring.

.DESCRIPTION
Reads a list of machine names, runs remote network diagnostics, and stores
timestamped reports locally. Includes error handling, directory validation,
and clean output formatting.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

# ---------------------------------------------
# Configuration
# ---------------------------------------------
$MachineListPath = "C:\MSP\machines.txt"
$ReportPath      = "C:\MSP\NetworkHealthReports"

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

    Write-Host "Processing $Machine..."

    try {
        Invoke-Command -ComputerName $Machine -ErrorAction Stop -ScriptBlock {
            param($ReportPath)

            $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
            $reportFile = Join-Path $ReportPath "$env:COMPUTERNAME-NetworkHealth-$timestamp.txt"

            # Collect network adapter info
            $networkStatus = Get-NetAdapter |
                Select-Object Name, Status, MacAddress, LinkSpeed

            # Collect IP configuration
            $ipConfig = Get-NetIPAddress |
                Select-Object InterfaceAlias, IPAddress, AddressFamily, Type, PrefixOrigin

            # Build report
            $report = @()
            $report += "===== NETWORK HEALTH REPORT ====="
            $report += "Computer: $env:COMPUTERNAME"
            $report += "Generated: $(Get-Date)"
            $report += ""
            $report += "---- Network Adapters ----"
            $report += ($networkStatus | Out-String)
            $report += "---- IP Configuration ----"
            $report += ($ipConfig | Out-String)

            # Write report
            $report | Out-File -FilePath $reportFile -Encoding UTF8

            Write-Output "Report generated: $reportFile"
        } -ArgumentList $ReportPath
    }
    catch {
        Write-Host "ERROR: Unable to connect to $Machine. $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ---------------------------------------------
# Optional: Register Scheduled Task
# ---------------------------------------------
$action  = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\MSP\HealthScripts\NetworkHealth.ps1"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 5am

Register-ScheduledTask -Action $action `
                       -Trigger $trigger `
                       -TaskName "WeeklyNetworkHealthCheck" `
                       -Description "Performs weekly network health checks."
