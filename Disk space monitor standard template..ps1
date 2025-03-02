# List of remote machines
$machines = Get-Content -Path "C:\MSP\machines.txt"
# Email settings
$smtpServer = "smtp.example.com"
$from = "alerts@example.com"
$to = "admin@example.com"

foreach ($machine in $machines) {
    $diskSpace = Get-WmiObject Win32_LogicalDisk -ComputerName $machine -Filter "DriveType=3" | Select-Object DeviceID, @{Name="FreeSpaceGB";Expression={[math]::round($_.FreeSpace/1GB,2)}}
    
    foreach ($disk in $diskSpace) {
        if ($disk.FreeSpaceGB -lt 10) { # Trigger alert if free space is less than 10GB
            $subject = "Disk Space Alert on $machine"
            $body = "Warning: Low disk space on $machine. Drive $($disk.DeviceID) has only $($disk.FreeSpaceGB) GB free."
            Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $subject -Body $body
        }
    }
}
