# List of remote machines
$machines = Get-Content -Path "C:\MSP\machines.txt"
$reportPath = "C:\MSP\SecurityAuditReports"

foreach ($machine in $machines) {
    Invoke-Command -ComputerName $machine -ScriptBlock {
        # Check firewall status
        $firewallStatus = Get-NetFirewallProfile -Profile Domain,Public,Private | Select-Object Name, Enabled
        # Check antivirus status
        $avStatus = Get-MpComputerStatus | Select-Object AMRunningMode, AntispywareEnabled, AntivirusEnabled
        # Check Windows update status
        $updateStatus = Get-WindowsUpdateLog

        # Create a report
        $reportFile = "$reportPath\$env:COMPUTERNAME-SecurityAudit.txt"
        Add-Content -Path $reportFile -Value "Firewall Status:"
        $firewallStatus | Out-String | Add-Content -Path $reportFile
        Add-Content -Path $reportFile -Value "`nAntivirus Status:"
        $avStatus | Out-String | Add-Content -Path $reportFile
        Add-Content -Path $reportFile -Value "`nWindows Update Status:"
        $updateStatus | Out-String | Add-Content -Path $reportFile
        
        Write-Output "Security audit report generated for $env:COMPUTERNAME."
    }
}

# Schedule the audit script to run quarterly
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\MSP\AuditScripts\SecurityAudit.ps1"
$trigger = New-ScheduledTaskTrigger -Once -At "2024-01-01T00:00:00" -RepeatEvery "90 days"
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "QuarterlySecurityAudit" -Description "Performs security audits quarterly."
