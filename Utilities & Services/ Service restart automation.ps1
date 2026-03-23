# Script to monitor a service and restart if stopped
$serviceName = "ServiceName"
$service = Get-Service -Name $serviceName
if ($service.Status -ne "Running") {
    Start-Service -Name $serviceName
    Write-Output "Service $serviceName has been started."
} else {
    Write-Output "Service $serviceName is already running."
}
