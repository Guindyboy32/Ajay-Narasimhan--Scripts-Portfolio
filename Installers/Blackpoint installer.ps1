<#
.SYNOPSIS
    Installs the Blackpoint SNAP agent with proper validation, logging, and error handling.

.DESCRIPTION
    This script downloads and installs the SNAP agent based on environment variables
    provided by the deployment system. It validates .NET, checks for existing installs,
    downloads the installer, and executes it.

.NOTES
    Author: Ajay Narasimhan 
    Requires: PowerShell 5+, TLS 1.2+
#>

param(
    [switch]$Debug
)

# -----------------------------
# Configuration
# -----------------------------
$InstallerName   = "snap_installer.exe"
$InstallerPath   = Join-Path -Path $env:TEMP -ChildPath $InstallerName
$ServiceName     = "Snap"
$SitesEnabled    = [int]$env:SNAP_AllowSites

# Determine download URL
if ($SitesEnabled -eq 1) {
    $AccountUID = $env:SNAP_UID
    $CompanyEXE = $env:SNAP_FILE
    $DownloadURL = "https://portal.blackpointcyber.com/installer/$AccountUID/$CompanyEXE"
}
elseif ($SitesEnabled -eq 0) {
    $DownloadURL = $env:SNAP_DOWNLOAD
}
else {
    throw "Invalid value for SNAP_AllowSites environment variable."
}

# -----------------------------
# Logging
# -----------------------------
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "MM/dd/yy HH:mm:ss"
    Write-Output "[$timestamp] [$Level] $Message"
}

function Write-DebugLog {
    param([string]$Message)
    if ($Debug) {
        Write-Log -Message $Message -Level "DEBUG"
    }
}

# -----------------------------
# Validation Functions
# -----------------------------
function Test-ServiceExists {
    param([string]$Name)
    try {
        Get-Service -Name $Name -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Test-DotNet {
    Write-DebugLog "Checking for .NET 4.6.1+..."

    $release = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name Release -ErrorAction SilentlyContinue

    if (-not $release -or $release -lt 394254) {
        Write-Log "SNAP requires .NET Framework 4.6.1 or higher. Installation cannot continue." "ERROR"
        throw "Missing required .NET version."
    }

    Write-DebugLog ".NET 4.6.1+ detected."
}

# -----------------------------
# Download & Install
# -----------------------------
function Download-Installer {
    Write-DebugLog "Downloading installer from $DownloadURL"

    try {
        Invoke-WebRequest -Uri $DownloadURL -OutFile $InstallerPath -UseBasicParsing -ErrorAction Stop
    }
    catch {
        throw "Failed to download installer: $($_.Exception.Message)"
    }

    if (-not (Test-Path $InstallerPath)) {
        throw "Installer file not found after download."
    }

    Write-DebugLog "Installer downloaded to $InstallerPath"
}

function Install-Snap {
    Write-DebugLog "Verifying installer file exists..."

    if (-not (Test-Path $InstallerPath)) {
        throw "Installer file missing. AV or another process may have removed it."
    }

    Write-DebugLog "Running installer..."
    try {
        Start-Process -FilePath $InstallerPath -ArgumentList "-y" -NoNewWindow -Wait
    }
    catch {
        throw "Installer execution failed: $($_.Exception.Message)"
    }
}

# -----------------------------
# Main Execution
# -----------------------------
function Start-Installation {
    Write-DebugLog "Starting SNAP installation workflow..."

    if (Test-ServiceExists -Name $ServiceName) {
        Write-Log "SNAP is already installed. Exiting."
        return
    }

    Test-DotNet
    Download-Installer
    Install-Snap

    Write-Log "SNAP installation completed successfully."
}

try {
    Start-Installation
}
catch {
    Write-Log $_.Exception.Message "ERROR"
    exit 1
}

exit 0
