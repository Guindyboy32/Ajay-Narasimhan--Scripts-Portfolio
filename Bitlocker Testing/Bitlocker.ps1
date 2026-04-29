<#
.SYNOPSIS
    Enable BitLocker on local and remote machines and store recovery keys centrally.

.DESCRIPTION
    - Enables BitLocker on a specified drive (local + remote).
    - Stores recovery keys in a secure local path or network share.
    - Optionally sends an email notification per machine.
    - Includes validation, logging, and basic error handling.

.NOTES
    Replace placeholder values (SMTP, paths, share, etc.) before use.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$DriveLetter = 'C:',

    [Parameter(Mandatory = $false)]
    [string]$LocalKeyPath = 'C:\BitLockerRecoveryKeys',

    [Parameter(Mandatory = $false)]
    [string]$MachinesFile = 'C:\MSP\machines.txt',

    [Parameter(Mandatory = $false)]
    [string]$NetworkShare = '\\server\BitLockerRecoveryKeys',

    [Parameter(Mandatory = $false)]
    [string]$SmtpServer = 'smtp.example.com',

    [Parameter(Mandatory = $false)]
    [string]$From = 'alerts@example.com',

    [Parameter(Mandatory = $false)]
    [string]$To = 'admin@example.com',

    [Parameter(Mandatory = $false)]
    [switch]$EnableEmail
)

Write-Host "------------------------------------------------------------"
Write-Host " BitLocker Enablement & Recovery Key Collection"
Write-Host " Drive: $DriveLetter"
Write-Host " Local Key Path: $LocalKeyPath"
Write-Host " Network Share: $NetworkShare"
Write-Host " Machines File: $MachinesFile"
Write-Host " Email Enabled: $EnableEmail"
Write-Host "------------------------------------------------------------"

function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Enable-BitLockerAndStoreKey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DriveLetter,

        [Parameter(Mandatory = $true)]
        [string]$KeyPathRoot
    )

    $drive = $DriveLetter.TrimEnd(':')
    $bitLocker = Get-BitLockerVolume -MountPoint $DriveLetter -ErrorAction SilentlyContinue

    if (-not $bitLocker) {
        Write-Output "[$env:COMPUTERNAME] BitLocker not supported or drive not found: $DriveLetter."
        return $null
    }

    if ($bitLocker.VolumeStatus -ne 'FullyDecrypted') {
        Write-Output "[$env:COMPUTERNAME] BitLocker already enabled or in progress on $DriveLetter."
        return $null
    }

    Ensure-Directory -Path $KeyPathRoot

    $recoveryKeyPath = Join-Path -Path $KeyPathRoot -ChildPath "$($env:COMPUTERNAME)_${drive}_RecoveryKey.txt"

    Write-Output "[$env:COMPUTERNAME] Enabling BitLocker on $DriveLetter..."
    $result = Enable-BitLocker `
        -MountPoint $DriveLetter `
        -EncryptionMethod Aes256 `
        -RecoveryKeyPath $KeyPathRoot `
        -UsedSpaceOnly `
        -TpmProtector `
        -ErrorAction Stop

    if ($result -and $result.KeyProtector.RecoveryPassword) {
        $content = "Recovery Key for $DriveLetter on $($env:COMPUTERNAME): $($result.KeyProtector.RecoveryPassword)"
        Set-Content -Path $recoveryKeyPath -Value $content -Force
        Write-Output "[$env:COMPUTERNAME] BitLocker enabled. Recovery key saved to $recoveryKeyPath."
        return $recoveryKeyPath
    }
    else {
        Write-Output "[$env:COMPUTERNAME] BitLocker enablement returned no recovery key."
        return $null
    }
}

function Send-BitLockerNotification {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        [Parameter(Mandatory = $true)]
        [string]$DriveLetter,

        [Parameter(Mandatory = $true)]
        [string]$RecoveryKeyPath,

        [Parameter(Mandatory = $true)]
        [string]$SmtpServer,

        [Parameter(Mandatory = $true)]
        [string]$From,

        [Parameter(Mandatory = $true)]
        [string]$To
    )

    $subject = "BitLocker Enabled on $ComputerName"
    $body = @"
BitLocker has been successfully enabled.

Computer: $ComputerName
Drive:    $DriveLetter
Key Path: $RecoveryKeyPath
"@

    try {
        Send-MailMessage -SmtpServer $SmtpServer -From $From -To $To -Subject $subject -Body $body
        Write-Output "[$ComputerName] Notification email sent."
    }
    catch {
        Write-Output "[$ComputerName] Failed to send notification email. $_"
    }
}

# -----------------------------
# LOCAL MACHINE
# -----------------------------
Write-Host "Processing local machine: $env:COMPUTERNAME" -ForegroundColor Cyan
try {
    Ensure-Directory -Path $LocalKeyPath
    $localKeyPath = Enable-BitLockerAndStoreKey -DriveLetter $DriveLetter -KeyPathRoot $LocalKeyPath

    if ($EnableEmail -and $localKeyPath) {
        Send-BitLockerNotification `
            -ComputerName $env:COMPUTERNAME `
            -DriveLetter $DriveLetter `
            -RecoveryKeyPath $localKeyPath `
            -SmtpServer $SmtpServer `
            -From $From `
            -To $To
    }
}
catch {
    Write-Output "[LOCAL] Error enabling BitLocker: $_"
}

# -----------------------------
# REMOTE MACHINES
# -----------------------------
if (Test-Path -Path $MachinesFile) {
    $machines = Get-Content -Path $MachinesFile | Where-Object { $_ -and $_.Trim() -ne '' }

    foreach ($machine in $machines) {
        Write-Host "Processing remote machine: $machine" -ForegroundColor Cyan

        try {
            Invoke-Command -ComputerName $machine -ScriptBlock {
                param (
                    $DriveLetter,
                    $NetworkShare,
                    $EnableEmail,
                    $SmtpServer,
                    $From,
                    $To
                )

                function Ensure-Directory {
                    param([string]$Path)
                    if (-not (Test-Path -Path $Path)) {
                        New-Item -ItemType Directory -Path $Path -Force | Out-Null
                    }
                }

                function Enable-BitLockerAndStoreKey {
                    param(
                        [string]$DriveLetter,
                        [string]$KeyPathRoot
                    )

                    $drive = $DriveLetter.TrimEnd(':')
                    $bitLocker = Get-BitLockerVolume -MountPoint $DriveLetter -ErrorAction SilentlyContinue

                    if (-not $bitLocker) {
                        Write-Output "[$env:COMPUTERNAME] BitLocker not supported or drive not found: $DriveLetter."
                        return $null
                    }

                    if ($bitLocker.VolumeStatus -ne 'FullyDecrypted') {
                        Write-Output "[$env:COMPUTERNAME] BitLocker already enabled or in progress on $DriveLetter."
                        return $null
                    }

                    Ensure-Directory -Path $KeyPathRoot

                    $recoveryKeyPath = Join-Path -Path $KeyPathRoot -ChildPath "$($env:COMPUTERNAME)_${drive}_RecoveryKey.txt"

                    Write-Output "[$env:COMPUTERNAME] Enabling BitLocker on $DriveLetter..."
                    $result = Enable-BitLocker `
                        -MountPoint $DriveLetter `
                        -EncryptionMethod Aes256 `
                        -RecoveryKeyPath $KeyPathRoot `
                        -UsedSpaceOnly `
                        -TpmProtector `
                        -ErrorAction Stop

                    if ($result -and $result.KeyProtector.RecoveryPassword) {
                        $content = "Recovery Key for $DriveLetter on $($env:COMPUTERNAME): $($result.KeyProtector.RecoveryPassword)"
                        Set-Content -Path $recoveryKeyPath -Value $content -Force
                        Write-Output "[$env:COMPUTERNAME] BitLocker enabled. Recovery key saved to $recoveryKeyPath."
                        return $recoveryKeyPath
                    }
                    else {
                        Write-Output "[$env:COMPUTERNAME] BitLocker enablement returned no recovery key."
                        return $null
                    }
                }

                function Send-BitLockerNotification {
                    param(
                        [string]$ComputerName,
                        [string]$DriveLetter,
                        [string]$RecoveryKeyPath,
                        [string]$SmtpServer,
                        [string]$From,
                        [string]$To
                    )

                    $subject = "BitLocker Enabled on $ComputerName"
                    $body = @"
BitLocker has been successfully enabled.

Computer: $ComputerName
Drive:    $DriveLetter
Key Path: $RecoveryKeyPath
"@

                    try {
                        Send-MailMessage -SmtpServer $SmtpServer -From $From -To $To -Subject $subject -Body $body
                        Write-Output "[$ComputerName] Notification email sent."
                    }
                    catch {
                        Write-Output "[$ComputerName] Failed to send notification email. $_"
                    }
                }

                $keyPath = Enable-BitLockerAndStoreKey -DriveLetter $DriveLetter -KeyPathRoot $NetworkShare

                if ($EnableEmail -and $keyPath) {
                    Send-BitLockerNotification `
                        -ComputerName $env:COMPUTERNAME `
                        -DriveLetter $DriveLetter `
                        -RecoveryKeyPath $keyPath `
                        -SmtpServer $SmtpServer `
                        -From $From `
                        -To $To
                }

            } -ArgumentList $DriveLetter, $NetworkShare, $EnableEmail, $SmtpServer, $From, $To -ErrorAction Stop

            Write-Output "[$machine] BitLocker processing completed."
        }
        catch {
            Write-Output "[$machine] Error during BitLocker processing: $_"
        }
    }
}
else {
    Write-Output "Machines file not found: $MachinesFile"
}
