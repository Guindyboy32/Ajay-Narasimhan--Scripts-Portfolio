<#
.SYNOPSIS
    GUI tool to create Remote Mailboxes in a Hybrid Exchange environment.

.DESCRIPTION
    Validates:
        - On‑prem Exchange connectivity
        - AD user existence
        - Existing mailbox presence

    Creates a remote mailbox safely and logs all actions.

.VERSION
    2.0 

.AUTHOR
    Ajay Narasimhan
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==========================
# CONFIGURATION
# ==========================
$PrimaryDomain = "testdomain.com"
$RemoteRoutingDomain = "testdomain2.mail.onmicrosoft.com"
$LogPath = "$env:USERPROFILE\RemoteMailboxTool.log"

# ==========================
# LOGGING
# ==========================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "[$timestamp][$Level] $Message"
}

# ==========================
# VALIDATION FUNCTIONS
# ==========================
function Test-ExchangeConnection {
    try {
        Get-Mailbox -ResultSize 1 -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Test-ADUserExists {
    param([string]$Sam)

    try {
        Get-ADUser -Identity $Sam -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Test-MailboxExists {
    param([string]$Sam)

    try {
        Get-Mailbox -Identity $Sam -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# ==========================
# GUI SETUP
# ==========================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Remote Mailbox Creator (On‑Prem Edition)"
$form.Size = New-Object System.Drawing.Size(500,260)
$form.StartPosition = "CenterScreen"

$label = New-Object System.Windows.Forms.Label
$label.Text = "Enter username (samAccountName):"
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(300,20)
$form.Controls.Add($label)

$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Point(10,45)
$textbox.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($textbox)

$output = New-Object System.Windows.Forms.TextBox
$output.Location = New-Object System.Drawing.Point(10,140)
$output.Size = New-Object System.Drawing.Size(460,70)
$output.Multiline = $true
$output.ReadOnly = $true
$form.Controls.Add($output)

$button = New-Object System.Windows.Forms.Button
$button.Text = "Create Remote Mailbox"
$button.Location = New-Object System.Drawing.Point(10,80)
$button.Size = New-Object System.Drawing.Size(460,30)
$form.Controls.Add($button)

$status = New-Object System.Windows.Forms.Label
$status.Location = New-Object System.Drawing.Point(10,115)
$status.Size = New-Object System.Drawing.Size(460,20)
$form.Controls.Add($status)

# ==========================
# MAIN LOGIC
# ==========================
$button.Add_Click({
    $button.Enabled = $false
    $status.ForeColor = "Black"
    $output.Clear()

    $username = $textbox.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($username)) {
        $status.Text = "Username is required."
        $status.ForeColor = "Red"
        $button.Enabled = $true
        return
    }

    Write-Log "Starting mailbox creation for $username"

    # Validate Exchange connection
    if (-not (Test-ExchangeConnection)) {
        $status.Text = "Not connected to On‑Prem Exchange Management Shell."
        $status.ForeColor = "Red"
        Write-Log "Exchange connection missing" "ERROR"
        $button.Enabled = $true
        return
    }

    # Validate AD user
    if (-not (Test-ADUserExists -Sam $username)) {
        $status.Text = "AD user not found."
        $status.ForeColor = "Red"
        Write-Log "AD user $username not found" "ERROR"
        $button.Enabled = $true
        return
    }

    # Check if mailbox already exists
    if (Test-MailboxExists -Sam $username)) {
        $status.Text = "Mailbox already exists."
        $status.ForeColor = "Orange"
        Write-Log "Mailbox already exists for $username" "WARN"
        $button.Enabled = $true
        return
    }

    # Build addresses
    $primary = "$username@$PrimaryDomain"
    $remote  = "$username@$RemoteRoutingDomain"

    try {
        $status.Text = "Creating remote mailbox..."
        Write-Log "Running Enable-RemoteMailbox for $username"

        Enable-RemoteMailbox -Identity $username -RemoteRoutingAddress $remote -ErrorAction Stop
        Set-RemoteMailbox -Identity $username -EmailAddressPolicyEnabled $false -ErrorAction Stop
        Set-RemoteMailbox -Identity $username -PrimarySmtpAddress $primary -ErrorAction Stop

        $status.Text = "Mailbox created successfully."
        $status.ForeColor = "Green"
        $output.Text = "Primary SMTP: $primary`r`nRemote Routing: $remote"

        Write-Log "Mailbox created successfully for $username" "OK"
    }
    catch {
        $status.Text = "Error creating mailbox."
        $status.ForeColor = "Red"
        $output.Text = $_.Exception.Message
        Write-Log "Error creating mailbox: $($_.Exception.Message)" "ERROR"
    }

    $button.Enabled = $true
})

$form.ShowDialog()
