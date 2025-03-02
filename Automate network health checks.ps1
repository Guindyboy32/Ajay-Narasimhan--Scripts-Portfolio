# List of remote machines
$machines = Get-Content -Path "C:\MSP\machines.txt"
$reportPath = "C:\MSP\NetworkHealthReports"

foreach ($machine in $machines) {
    Invoke-Command -ComputerName $machine -ScriptBlock {
        # Check network adapter status
        $networkStatus = Get-NetAdapter | Select-Object Name, Status, MacAddress, LinkSpeed
        # Check IP configuration
        $ipConfig = Get-NetIPAddress | Select-Object InterfaceAlias, IPAddress, AddressFamily, Type, PrefixOrigin

        # Create a report
        $reportFile = "$reportPath\$env:COMPUTERNAME-NetworkHealth.txt"
        Add-Content -Path $reportFile -Value "Network Adapter Status:"
        $networkStatus | Out-String | Add-Content -Path $reportFile
        Add-Content -Path $reportFile -Value "`nIP Configuration:"
        $ipConfig | Out-String | Add-Content -Path $reportFile
        
        Write-Output "Network health report generated for $env:COMPUTERNAME."
    }
}

# Schedule the health check script to run weekly
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\MSP\HealthScripts\NetworkHealth.ps1"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 5am
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "WeeklyNetworkHealthCheck" -Description "Performs network health checks weekly."
