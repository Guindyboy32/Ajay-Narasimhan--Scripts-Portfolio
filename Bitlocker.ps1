# Define the drive to encrypt
$DriveLetter = "C:"
$SecurePath = "C:\BitLockerRecoveryKeys"

# Check if BitLocker is enabled on the drive
$BitLockerStatus = Get-BitLockerVolume -MountPoint $DriveLetter

if ($BitLockerStatus.VolumeStatus -eq "FullyDecrypted") {
    # Ensure the path for storing recovery keys exists
    if (-not (Test-Path -Path $SecurePath)) {
        New-Item -ItemType Directory -Path $SecurePath
    }

    # Generate a recovery key and store it in a secure location
    $RecoveryKeyPath = Join-Path -Path $SecurePath -ChildPath "$($env:COMPUTERNAME)_$($DriveLetter.TrimEnd(':'))_RecoveryKey.txt"
    $RecoveryKey = Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod Aes256 -RecoveryKeyPath $SecurePath -UsedSpaceOnly -TpmProtector -Verbose

    if ($RecoveryKey) {
        $RecoveryKeyContent = "Recovery Key for $DriveLetter on $($env:COMPUTERNAME): $($RecoveryKey.KeyProtector.RecoveryPassword)"
        Set-Content -Path $RecoveryKeyPath -Value $RecoveryKeyContent

        Write-Output "BitLocker enabled successfully on $DriveLetter. Recovery key saved to $RecoveryKeyPath."
    } else {
        Write-Output "Failed to enable BitLocker on $DriveLetter."
    }
} else {
    Write-Output "BitLocker is already enabled on $DriveLetter."
}



#------------------

# List of remote machines
$machines = Get-Content -Path "C:\MSP\machines.txt"
$SecureNetworkShare = "\\server\BitLockerRecoveryKeys"

foreach ($machine in $machines) {
    Invoke-Command -ComputerName $machine -ScriptBlock {
        param ($SecureNetworkShare)
        $DriveLetter = "C:"
        
        if ((Get-BitLockerVolume -MountPoint $DriveLetter).VolumeStatus -eq "FullyDecrypted") {
            if (-not (Test-Path -Path $SecureNetworkShare)) {
                New-Item -ItemType Directory -Path $SecureNetworkShare
            }
            $RecoveryKeyPath = Join-Path -Path $SecureNetworkShare -ChildPath "$($env:COMPUTERNAME)_$($DriveLetter.TrimEnd(':'))_RecoveryKey.txt"
            $RecoveryKey = Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod Aes256 -RecoveryKeyPath $SecureNetworkShare -UsedSpaceOnly -TpmProtector -Verbose
            if ($RecoveryKey) {
                $RecoveryKeyContent = "Recovery Key for $DriveLetter on $($env:COMPUTERNAME): $($RecoveryKey.KeyProtector.RecoveryPassword)"
                Set-Content -Path $RecoveryKeyPath -Value $RecoveryKeyContent
            }
        }
    } -ArgumentList $SecureNetworkShare
    Write-Output "Enabled BitLocker on $machine."
}


#----------------------

# List of remote machines
$machines = Get-Content -Path "C:\MSP\machines.txt"
$SecureNetworkShare = "\\server\BitLockerRecoveryKeys"
# Email settings
$smtpServer = "smtp.example.com"
$from = "alerts@example.com"
$to = "admin@example.com"

foreach ($machine in $machines) {
    Invoke-Command -ComputerName $machine -ScriptBlock {
        param ($SecureNetworkShare, $smtpServer, $from, $to)
        $DriveLetter = "C:"
        
        if ((Get-BitLockerVolume -MountPoint $DriveLetter).VolumeStatus -eq "FullyDecrypted") {
            if (-not (Test-Path -Path $SecureNetworkShare)) {
                New-Item -ItemType Directory -Path $SecureNetworkShare
            }
            $RecoveryKeyPath = Join-Path -Path $SecureNetworkShare -ChildPath "$($env:COMPUTERNAME)_$($DriveLetter.TrimEnd(':'))_RecoveryKey.txt"
            $RecoveryKey = Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod Aes256 -RecoveryKeyPath $SecureNetworkShare -UsedSpaceOnly -TpmProtector -Verbose
            if ($RecoveryKey) {
                $RecoveryKeyContent = "Recovery Key for $DriveLetter on $($env:COMPUTERNAME): $($RecoveryKey.KeyProtector.RecoveryPassword)"
                Set-Content -Path $RecoveryKeyPath -Value $RecoveryKeyContent
                # Send email notification
                $subject = "BitLocker Enabled on $($env:COMPUTERNAME)"
                $body = "BitLocker has been successfully enabled on $DriveLetter. Recovery key saved to $RecoveryKeyPath."
                Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject $subject -Body $body
            }
        }
    } -ArgumentList $SecureNetworkShare, $smtpServer, $from, $to
    Write-Output "Enabled BitLocker on $machine."
}

