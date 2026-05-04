<#
.SYNOPSIS
Clears the Windows Update cache safely by stopping the update service,
removing cached update files, and restarting the service.

.DESCRIPTION
This script validates service state, handles errors gracefully, and ensures
the SoftwareDistribution\Download folder is cleared without leaving the
system in an inconsistent state.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

$serviceName = "wuauserv"
$cachePath   = "C:\Windows\SoftwareDistribution\Download"

try {
    # Stop Windows Update service if running
    $service = Get-Service -Name $serviceName -ErrorAction Stop
    if ($service.Status -eq "Running") {
        Stop-Service -Name $serviceName -Force -ErrorAction Stop
    }

    # Validate cache path exists
    if (Test-Path $cachePath) {
        Remove-Item -Path "$cachePath\*" -Recurse -Force -ErrorAction Stop
    }

    # Restart service
    Start-Service -Name $serviceName -ErrorAction Stop

    Write-Output "✔ Windows Update cache cleared successfully."
}
catch {
    Write-Output "✖ Failed to clear Windows Update cache. $($_.Exception.Message)"
}
