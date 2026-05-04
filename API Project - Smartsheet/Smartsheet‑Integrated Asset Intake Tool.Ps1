Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ==========================
# CONFIGURATION
# ==========================
# Smartsheet API token (plaintext for demo/portfolio)
$SmartsheetToken = "<YOUR_SMARTSHEET_API_TOKEN_HERE>"
$SmartsheetBaseUrl = "https://api.smartsheet.com/2.0"

# Column IDs in the target Smartsheet (must exist in each sheet you use)
# Set these to the column IDs for: Asset Tag, Serial, Model, Timestamp
$AssetTagColumnId = 1111111111111111
$SerialColumnId   = 2222222222222222
$ModelColumnId    = 3333333333333333
$TimestampColumnId= 4444444444444444

# Local output folder
$OutputFolder = "C:\Temp\AssetTool"
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}

$CsvPath  = Join-Path $OutputFolder "AssetCapture.csv"
$JsonPath = Join-Path $OutputFolder "AssetCapture.json"
$LogPath  = Join-Path $OutputFolder "AssetTool.log"

# ==========================
# HELPER: Logging
# ==========================
function Write-Log {
    param(
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp`t$Message" | Out-File -FilePath $LogPath -Append -Encoding UTF8
}

# ==========================
# HELPER: Smartsheet API
# ==========================
function Invoke-Smartsheet {
    param(
        [string]$Method,
        [string]$Uri,
        [object]$Body = $null
    )

    $headers = @{
        "Authorization" = "Bearer $SmartsheetToken"
        "Content-Type"  = "application/json"
    }

    try {
        if ($Body) {
            $json = $Body | ConvertTo-Json -Depth 10
            return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -Body $json
        }
        else {
            return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers
        }
    }
    catch {
        Write-Log "Smartsheet API error: $($_.Exception.Message)"
        [System.Windows.Forms.MessageBox]::Show("Smartsheet API error. Check log at $LogPath","Error")
        return $null
    }
}

# ==========================
# GET SHEETS FOR DROPDOWN
# ==========================
$Sheets = Invoke-Smartsheet -Method "GET" -Uri "$SmartsheetBaseUrl/sheets"
if (-not $Sheets) {
    [System.Windows.Forms.MessageBox]::Show("Unable to retrieve Smartsheet sheets. Exiting.","Error")
    return
}

# ==========================
# BUILD GUI
# ==========================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Asset Tag Entry (Smartsheet Integrated)"
$form.Size = New-Object System.Drawing.Size(450,320)
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
    $box.Width = 250
    $form.Controls.Add($box)
    $boxes += $box
}

# Auto-populate Serial + Model
try {
    $boxes[1].Text = (Get-WmiObject Win32_BIOS).SerialNumber
    $boxes[2].Text = (Get-WmiObject Win32_ComputerSystem).Model
}
catch {
    Write-Log "WMI error: $($_.Exception.Message)"
}

# Sheet selection label
$sheetLabel = New-Object System.Windows.Forms.Label
$sheetLabel.Text = "Smartsheet:"
$sheetLabel.Location = New-Object System.Drawing.Point(10, 140)
$sheetLabel.AutoSize = $true
$form.Controls.Add($sheetLabel)

# Sheet dropdown
$sheetDropdown = New-Object System.Windows.Forms.ComboBox
$sheetDropdown.Location = New-Object System.Drawing.Point(150, 135)
$sheetDropdown.Width = 250
$sheetDropdown.DropDownStyle = "DropDownList"
$form.Controls.Add($sheetDropdown)

# Populate dropdown with sheet names
foreach ($sheet in $Sheets.data) {
    $item = New-Object PSObject -Property @{
        Name = $sheet.name
        Id   = $sheet.id
    }
    [void]$sheetDropdown.Items.Add($item)
}
$sheetDropdown.DisplayMember = "Name"
$sheetDropdown.ValueMember   = "Id"
if ($sheetDropdown.Items.Count -gt 0) { $sheetDropdown.SelectedIndex = 0 }

# Buttons
$submit = New-Object System.Windows.Forms.Button
$submit.Text = "Submit"
$submit.Location = New-Object System.Drawing.Point(150, 200)
$form.Controls.Add($submit)

$clear = New-Object System.Windows.Forms.Button
$clear.Text = "Clear"
$clear.Location = New-Object System.Drawing.Point(250, 200)
$form.Controls.Add($clear)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = ""
$statusLabel.Location = New-Object System.Drawing.Point(10, 240)
$statusLabel.AutoSize = $true
$form.Controls.Add($statusLabel)

# ==========================
# HELPER: Save Local
# ==========================
function Save-LocalData {
    param(
        [string]$AssetTag,
        [string]$Serial,
        [string]$Model
    )

    $data = [PSCustomObject]@{
        AssetTag  = $AssetTag
        Serial    = $Serial
        Model     = $Model
        Timestamp = (Get-Date)
    }

    $data | Export-Csv -Path $CsvPath -Append -NoTypeInformation
    $data | ConvertTo-Json | Out-File $JsonPath -Append
}

# ==========================
# HELPER: Find row by AssetTag
# ==========================
function Get-SmartsheetRowByAssetTag {
    param(
        [string]$SheetId,
        [string]$AssetTag
    )

    $sheet = Invoke-Smartsheet -Method "GET" -Uri "$SmartsheetBaseUrl/sheets/$SheetId"
    if (-not $sheet) { return $null }

    foreach ($row in $sheet.rows) {
        foreach ($cell in $row.cells) {
            if ($cell.columnId -eq $AssetTagColumnId -and $cell.value -eq $AssetTag) {
                return $row
            }
        }
    }
    return $null
}

# ==========================
# SUBMIT LOGIC (CREATE or UPDATE)
# ==========================
$submit.Add_Click({
    $assetTag = $boxes[0].Text
    $serial   = $boxes[1].Text
    $model    = $boxes[2].Text

    # Validation
    if ([string]::IsNullOrWhiteSpace($assetTag) -or
        [string]::IsNullOrWhiteSpace($serial) -or
        [string]::IsNullOrWhiteSpace($model)) {

        [System.Windows.Forms.MessageBox]::Show("All fields are required.","Validation Error")
        return
    }

    if (-not $sheetDropdown.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Please select a Smartsheet.","Validation Error")
        return
    }

    $selectedSheet = $sheetDropdown.SelectedItem
    $sheetId = $selectedSheet.Id

    $statusLabel.Text = "Checking Smartsheet for existing asset..."
    $form.Refresh()

    # Check if row exists (by AssetTag)
    $existingRow = Get-SmartsheetRowByAssetTag -SheetId $sheetId -AssetTag $assetTag

    $timestamp = (Get-Date).ToString("s")

    if ($existingRow) {
        # UPDATE existing row
        $statusLabel.Text = "Updating existing row in Smartsheet..."
        $form.Refresh()

        $updateBody = @(
            @{
                id    = $existingRow.id
                cells = @(
                    @{ columnId = $AssetTagColumnId;  value = $assetTag },
                    @{ columnId = $SerialColumnId;    value = $serial },
                    @{ columnId = $ModelColumnId;     value = $model },
                    @{ columnId = $TimestampColumnId; value = $timestamp }
                )
            }
        )

        $result = Invoke-Smartsheet -Method "PUT" -Uri "$SmartsheetBaseUrl/rows" -Body $updateBody
        if ($result) {
            Write-Log "Updated Smartsheet row for AssetTag '$assetTag' in sheet '$($selectedSheet.Name)'."
            Save-LocalData -AssetTag $assetTag -Serial $serial -Model $model
            $statusLabel.Text = "Updated existing asset in Smartsheet and saved locally."
        }
    }
    else {
        # CREATE new row
        $statusLabel.Text = "Creating new row in Smartsheet..."
        $form.Refresh()

        $createBody = @{
            toBottom = $true
            rows     = @(
                @{
                    cells = @(
                        @{ columnId = $AssetTagColumnId;  value = $assetTag },
                        @{ columnId = $SerialColumnId;    value = $serial },
                        @{ columnId = $ModelColumnId;     value = $model },
                        @{ columnId = $TimestampColumnId; value = $timestamp }
                    )
                }
            )
        }

        $result = Invoke-Smartsheet -Method "POST" -Uri "$SmartsheetBaseUrl/sheets/$sheetId/rows" -Body $createBody
        if ($result) {
            Write-Log "Created Smartsheet row for AssetTag '$assetTag' in sheet '$($selectedSheet.Name)'."
            Save-LocalData -AssetTag $assetTag -Serial $serial -Model $model
            $statusLabel.Text = "Created new asset in Smartsheet and saved locally."
        }
    }

    $form.Refresh()
})

# ==========================
# CLEAR LOGIC
# ==========================
$clear.Add_Click({
    foreach ($box in $boxes) { $box.Clear() }

    try {
        $boxes[1].Text = (Get-WmiObject Win32_BIOS).SerialNumber
        $boxes[2].Text = (Get-WmiObject Win32_ComputerSystem).Model
    }
    catch {
        Write-Log "WMI error on clear: $($_.Exception.Message)"
    }

    $statusLabel.Text = "Cleared. Ready for next entry."
})

$form.ShowDialog()
