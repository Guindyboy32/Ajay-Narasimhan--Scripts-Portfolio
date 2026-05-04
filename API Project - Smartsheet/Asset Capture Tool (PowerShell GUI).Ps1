<#
.SYNOPSIS
Asset intake GUI tool with validation, logging, and structured output.

.DESCRIPTION
This tool captures Asset Tag, Serial Number, and Model from a technician,
auto‑populates hardware info via WMI, validates input, logs actions, and
writes structured CSV + JSON output. Designed for enterprise intake workflows.

Author: Ajay Narasimhan – Senior Systems Engineer
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==========================
# CONFIGURATION
# ==========================
$OutputFolder = "C:\Temp\AssetTool"
$CsvPath      = Join-Path $OutputFolder "AssetCapture.csv"
$JsonPath     = Join-Path $OutputFolder "AssetCapture.json"
$LogPath      = Join-Path $OutputFolder "AssetTool.log"

if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

# ==========================
# LOGGING
# ==========================
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp`t$Message" | Out-File -FilePath $LogPath -Append -Encoding UTF8
}

# ==========================
# WMI HELPERS
# ==========================
function Get-SerialSafe {
    try {
        return (Get-WmiObject Win32_BIOS).SerialNumber
    }
    catch {
        Write-Log "WMI Serial error: $($_.Exception.Message)"
        return ""
    }
}

function Get-ModelSafe {
    try {
        return (Get-WmiObject Win32_ComputerSystem).Model
    }
    catch {
        Write-Log "WMI Model error: $($_.Exception.Message)"
        return ""
    }
}

# ==========================
# SAVE DATA
# ==========================
function Save-AssetData {
    param(
        [string]$AssetTag,
        [string]$Serial,
        [string]$Model
    )

    $record = [PSCustomObject]@{
        AssetTag  = $AssetTag
        Serial    = $Serial
        Model     = $Model
        Timestamp = (Get-Date)
    }

    try {
        $record | Export-Csv -Path $CsvPath -Append -NoTypeInformation
        $record | ConvertTo-Json | Out-File $JsonPath -Append
        Write-Log "Saved asset: $AssetTag / $Serial / $Model"
    }
    catch {
        Write-Log "Save error: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show("Failed to save data. Check log.","Error")
    }
}

# ==========================
# BUILD GUI
# ==========================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Asset Tag Entry"
$form.Size = New-Object System.Drawing.Size(420,330)
$form.StartPosition = "CenterScreen"

$labels = "Asset Tag","Serial Number","Model"
$boxes = @()

for ($i=0; $i -lt $labels.Count; $i++) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $labels[$i]
    $label.Location = New-Object System.Drawing.Point(10,20 + ($i*40))
    $label.AutoSize = $true
    $form.Controls.Add($label)

    $box = New-Object System.Windows.Forms.TextBox
    $box.Location = New-Object System.Drawing.Point(150,20 + ($i*40))
    $box.Width = 230
    $form.Controls.Add($box)
    $boxes += $box
}

# Auto-populate
$boxes[1].Text = Get-SerialSafe
$boxes[2].Text = Get-ModelSafe

# Status label
$status = New-Object System.Windows.Forms.Label
$status.Text = ""
$status.Location = New-Object System.Drawing.Point(10, 220)
$status.AutoSize = $true
$form.Controls.Add($status)

# Buttons
$submit = New-Object System.Windows.Forms.Button
$submit.Text = "Submit"
$submit.Location = New-Object System.Drawing.Point(150, 180)
$form.Controls.Add($submit)

$clear = New-Object System.Windows.Forms.Button
$clear.Text = "Clear"
$clear.Location = New-Object System.Drawing.Point(250, 180)
$form.Controls.Add($clear)

# ==========================
# SUBMIT LOGIC
# ==========================
$submit.Add_Click({
    $assetTag = $boxes[0].Text.Trim()
    $serial   = $boxes[1].Text.Trim()
    $model    = $boxes[2].Text.Trim()

    # Validation
    if ($assetTag -eq "" -or $serial -eq "" -or $model -eq "") {
        [System.Windows.Forms.MessageBox]::Show("All fields are required.","Validation Error")
        return
    }

    $status.Text = "Saving..."
    $form.Refresh()

    Save-AssetData -AssetTag $assetTag -Serial $serial -Model $model

    $status.Text = "Saved successfully."
    [System.Windows.Forms.MessageBox]::Show("Saved successfully.`nForm will now close.")
    $form.Close()
})

# ==========================
# CLEAR LOGIC
# ==========================
$clear.Add_Click({
    foreach ($box in $boxes) { $box.Clear() }
    $boxes[1].Text = Get-SerialSafe
    $boxes[2].Text = Get-ModelSafe
    $status.Text = "Cleared."
})

$form.ShowDialog()
