<#
.SYNOPSIS
    Grants calendar permissions (including private item visibility) to a delegate.

.DESCRIPTION
    - Validates mailbox and delegate existence
    - Grants Editor or custom access rights
    - Optionally enables viewing private items
    - Logs all actions
    - Provides summary reporting

.NOTES
    Requires Exchange Online PowerShell module.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxOwner,

    [Parameter(Mandatory = $true)]
    [string]$Delegate,

    [Parameter(Mandatory = $false)]
    [ValidateSet("Reviewer","Author","Editor","PublishingEditor","Owner")]
    [string]$AccessLevel = "Editor",

    [switch]$AllowPrivateItems,

    [string]$LogPath = "C:\MSP\CalendarDelegationLogs"
)

# -----------------------------
# Helper Functions
# -----------------------------

function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp  $Message" | Out-File -FilePath $Global:LogFile -Append
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Validate-Mailbox {
    param([string]$UPN)

    try {
        Get-Mailbox -Identity $UPN -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# -----------------------------
# Initialization
# -----------------------------

Ensure-Directory -Path $LogPath
$Global:LogFile = Join-Path $LogPath ("CalendarDelegation_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt")

Write-Log "Starting calendar delegation process..."
Write-Log "Mailbox Owner: $MailboxOwner"
Write-Log "Delegate: $Delegate"
Write-Log "Access Level: $AccessLevel"
Write-Log "Allow Private Items: $AllowPrivateItems"

# -----------------------------
# Validation
# -----------------------------

if (-not (Validate-Mailbox -UPN $MailboxOwner)) {
    Write-Log "ERROR: Mailbox owner not found: $MailboxOwner"
    Write-Host "Mailbox owner not found: $MailboxOwner" -ForegroundColor Red
    exit 1
}

if (-not (Validate-Mailbox -UPN $Delegate)) {
    Write-Log "ERROR: Delegate mailbox not found: $Delegate"
    Write-Host "Delegate mailbox not found: $Delegate" -ForegroundColor Red
    exit 1
}

# -----------------------------
# Apply Permissions
# -----------------------------

try {
    Write-Log "Applying $AccessLevel permissions to $Delegate..."

    Add-MailboxFolderPermission `
        -Identity "$MailboxOwner:\Calendar" `
        -User $Delegate `
        -AccessRights $AccessLevel `
        -ErrorAction Stop

    Write-Log "Base permissions applied successfully."
}
catch {
    Write-Log "ERROR applying base permissions: $_"
    Write-Host "Failed to apply base permissions." -ForegroundColor Red
}

# -----------------------------
# Private Items Access
# -----------------------------

if ($AllowPrivateItems) {
    try {
        Write-Log "Enabling private item visibility..."

        Set-MailboxFolderPermission `
            -Identity "$MailboxOwner:\Calendar" `
            -User $Delegate `
            -AccessRights $AccessLevel `
            -SharingPermissionFlags Delegate,CanViewPrivateItems `
            -ErrorAction Stop

        Write-Log "Private item visibility enabled."
    }
    catch {
        Write-Log "ERROR enabling private item visibility: $_"
        Write-Host "Failed to enable private item visibility." -ForegroundColor Red
    }
}

# -----------------------------
# Verification
# -----------------------------

try {
    Write-Log "Retrieving final permissions..."
    $final = Get-MailboxFolderPermission -Identity "$MailboxOwner:\Calendar"
    Write-Log "Final permissions retrieved successfully."
}
catch {
    Write-Log "ERROR retrieving final permissions: $_"
}

Write-Host "`nCalendar delegation completed. Log saved to $Global:LogFile" -ForegroundColor Green
