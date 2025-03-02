# Define parameters
$resourceGroupName = "MyResourceGroup"
$vmScaleSetName = "MyVMSS"
$cpuThreshold = 75

# Get the VM scale set
$vmss = Get-AzVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $vmScaleSetName

# Check CPU usage and scale up if necessary
$metrics = Get-AzMetric -ResourceId $vmss.Id -MetricName "Percentage CPU" -TimeGrain "PT1M" -StartTime (Get-Date).AddMinutes(-10) -EndTime (Get-Date)
$averageCpu = ($metrics.Data | Measure-Object -Property Average -Average).Average
if ($averageCpu -gt $cpuThreshold) {
    $vmss.Sku.Capacity += 1
    Update-AzVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $vmScaleSetName -Sku $vmss.Sku
    Write-Output "Scaled up VMSS by one instance due to high CPU usage."
} else {
    Write-Output "CPU usage is within the threshold."
}
