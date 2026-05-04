Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =========================
# CONFIG
# =========================

$Global:LogFolder = "C:\TestDomainOnboardingLogs"
if (-not (Test-Path $Global:LogFolder)) {
    New-Item -Path $Global:LogFolder -ItemType Directory | Out-Null
}
$Global:LogFile = Join-Path $Global:LogFolder ("Onboarding_{0:yyyyMMdd}.log" -f (Get-Date))

function Write-TestDomainLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $line = "{0:yyyy-MM-dd HH:mm:ss} [{1}] {2}" -f (Get-Date), $Level, $Message
    Add-Content -Path $Global:LogFile -Value $line
}

# =========================
# FUNCTIONS (LOGIC LAYER)
# =========================

function New-TestDomainUser {
    param(
        [string]$FirstName,
        [string]$LastName,
        [string]$Sam,
        [string]$Title,
        [string]$Department,
        [string]$EmployeeType,
        [datetime]$StartDate,
        [string]$Template,
        [securestring]$Password
    )

    try {
        Write-TestDomainLog "Creating AD user $Sam"
        $templateUser = Get-ADUser $Template -Properties * -ErrorAction Stop

        New-ADUser `
            -SamAccountName $Sam `
            -UserPrincipalName "$Sam@TestDomain.com" `
            -Name "$FirstName $LastName" `
            -GivenName $FirstName `
            -Surname $LastName `
            -Enabled $true `
            -AccountPassword $Password `
            -Instance $templateUser `
            -Path "OU=TestDomain,OU=SiteA,OU=TestDomainUsers,DC=TestDoamin,DC=com" `
            -ErrorAction Stop

        Write-TestDomainLog "Successfully created AD user $Sam"
        return "Created AD user $Sam"
    }
    catch {
        $err = "Error creating AD user $Sam: $($_.Exception.Message)"
        Write-TestDomainLog $err "ERROR"
        return $err
    }
}

function Set-TestDomainAttributes {
    param(
        [string]$Sam,
        [hashtable]$ExtensionAttributes,
        [string]$Title,
        [string]$Department,
        [string]$StreetAddress
    )

    try {
        Write-TestDomainLog "Applying attributes for $Sam"

        if ($ExtensionAttributes) {
            Set-ADUser $Sam -Add $ExtensionAttributes -ErrorAction Stop
        }

        Set-ADUser $Sam `
            -Title $Title `
            -Department $Department `
            -StreetAddress $StreetAddress `
            -ErrorAction Stop

        Write-TestDomainLog "Successfully applied attributes for $Sam"
        return "Applied attributes for $Sam"
    }
    catch {
        $err = "Error applying attributes for $Sam: $($_.Exception.Message)"
        Write-TestDomainLog $err "ERROR"
        return $err
    }
}

function Set-TestDomainManager {
    param(
        [string]$Sam,
        [string]$ManagerEmployeeId
    )

    try {
        Write-TestDomainLog "Looking up manager by EmployeeID $ManagerEmployeeId for $Sam"
        $manager = Get-ADUser -Filter "employeeID -eq '$ManagerEmployeeId'" -Properties DistinguishedName -ErrorAction Stop

        if ($manager) {
            Set-ADUser $Sam -Manager $manager.DistinguishedName -ErrorAction Stop
            $msg = "Manager set for $Sam: $($manager.DistinguishedName)"
            Write-TestDomainLog $msg
            return $msg
        }
        else {
            $msg = "Manager not found for EmployeeID $ManagerEmployeeId. Skipping manager update for $Sam."
            Write-TestDomainLog $msg "WARN"
            return $msg
        }
    }
    catch {
        $err = "Error setting manager for $Sam: $($_.Exception.Message)"
        Write-TestDomainLog $err "ERROR"
        return $err
    }
}

function Enable-TestDomainRemoteMailbox {
    param(
        [string]$Sam,
        [string]$PrimarySmtp,
        [string]$RemoteRouting
    )

    try {
        Write-TestDomainLog "Enabling remote mailbox for $Sam with $RemoteRouting"
        Enable-RemoteMailbox -Identity $Sam -RemoteRoutingAddress $RemoteRouting -ErrorAction Stop

        try {
            Set-RemoteMailbox -Identity $Sam -PrimarySmtpAddress $PrimarySmtp -EmailAddressPolicyEnabled $true -ErrorAction Stop
            Write-TestDomainLog "Primary SMTP $PrimarySmtp applied with policy enabled for $Sam"
        }
        catch {
            Write-TestDomainLog "Policy conflict for $Sam, retrying with EmailAddressPolicyEnabled = \$false" "WARN"
            Set-RemoteMailbox -Identity $Sam -PrimarySmtpAddress $PrimarySmtp -EmailAddressPolicyEnabled $false -ErrorAction Stop
            Write-TestDomainLog "Primary SMTP $PrimarySmtp applied with policy disabled for $Sam"
        }

        $msg = "Remote mailbox created for $Sam with $PrimarySmtp"
        Write-TestDomainLog $msg
        return $msg
    }
    catch {
        $err = "Error creating remote mailbox for $Sam: $($_.Exception.Message)"
        Write-TestDomainLog $err "ERROR"
        return $err
    }
}

function Validate-TestDomainMailbox {
    param([string]$Sam)

    try {
        Write-TestDomainLog "Validating remote mailbox for $Sam"
        $mbx = Get-RemoteMailbox $Sam -ErrorAction Stop
        $out = $mbx | Select Name,PrimarySmtpAddress,EmailAddresses | Out-String
        Write-TestDomainLog "Validation complete for $Sam"
        return $out
    }
    catch {
        $err = "Remote mailbox not found or error for $Sam: $($_.Exception.Message)"
        Write-TestDomainLog $err "ERROR"
        return $err
    }
}

function Run-TestDomainBulkOnboarding {
    param([string]$CsvPath)

    if (-not (Test-Path $CsvPath)) {
        $msg = "CSV not found: $CsvPath"
        Write-TestDomainLog $msg "ERROR"
        return $msg
    }

    $users = Import-Csv $CsvPath
    $log = New-Object System.Text.StringBuilder
    [void]$log.AppendLine("Loaded $($users.Count) users from $CsvPath")

    foreach ($u in $users) {
        $sam = $u.samAccountName
        $primary = "$sam@TestDomain.com"
        $remote  = "$sam@TestDomain2.mail.onmicrosoft.com"

        [void]$log.AppendLine("Processing $sam...")
        Write-TestDomainLog "Bulk: processing $sam"

        try {
            $pwd = ConvertTo-SecureString $u.Password -AsPlainText -Force

            $msg1 = New-TestDomainrUser -FirstName $u.FirstName `
                                   -LastName $u.LastName `
                                   -Sam $sam `
                                   -Title $u.Title `
                                   -Department $u.Department `
                                   -EmployeeType $u.EmployeeType `
                                   -StartDate $u.StartDate `
                                   -Template $u.Template `
                                   -Password $pwd
            [void]$log.AppendLine("  $msg1")

            $ext = @{
                extensionAttribute1  = $u.FullNameCaps
                extensionAttribute2  = $u.ManagerID
                extensionAttribute3  = $u.DeptSRVPName
                extensionAttribute4  = $u.DeptSRVPID
                extensionAttribute5  = $u.EmployeeLevel
                extensionAttribute10 = $u.StartDate
                extensionAttribute11 = $u.VPID
                extensionAttribute12 = $u.VPName
                extensionAttribute14 = $u.StartDate
                extensionAttribute15 = $u.EmployeeType
            }

            $msg2 = Set-TestDomainAttributes -Sam $sam `
                                         -ExtensionAttributes $ext `
                                         -Title $u.Title `
                                         -Department $u.Department `
                                         -StreetAddress $u.StreetAddress
            [void]$log.AppendLine("  $msg2")

            $msg3 = TestDomainManager -Sam $sam -ManagerEmployeeId $u.ManagerID
            [void]$log.AppendLine("  $msg3")

            $msg4 = Enable-TestDomainRemoteMailbox -Sam $sam -PrimarySmtp $primary -RemoteRouting $remote
            [void]$log.AppendLine("  $msg4")
        }
        catch {
            $err = "Bulk error for $sam: $($_.Exception.Message)"
            Write-TestDomainLog $err "ERROR"
            [void]$log.AppendLine("  $err")
        }
    }

    return $log.ToString()
}

# =========================
# GUI (PRESENTATION LAYER)
# =========================

$form               = New-Object System.Windows.Forms.Form
$form.Text          = "TestDomain Onboarding Suite"
$form.Size          = New-Object System.Drawing.Size(800,600)
$form.StartPosition = "CenterScreen"

$tabControl        = New-Object System.Windows.Forms.TabControl
$tabControl.Dock   = 'Fill'

$tabUserInfo       = New-Object System.Windows.Forms.TabPage
$tabUserInfo.Text  = "User Info"

$tabMailbox        = New-Object System.Windows.Forms.TabPage
$tabMailbox.Text   = "Mailbox"

$tabBulk           = New-Object System.Windows.Forms.TabPage
$tabBulk.Text      = "Bulk"

$tabLogs           = New-Object System.Windows.Forms.TabPage
$tabLogs.Text      = "Logs"

$tabControl.TabPages.AddRange(@($tabUserInfo, $tabMailbox, $tabBulk, $tabLogs))
$form.Controls.Add($tabControl)

# =========================
# USER INFO TAB CONTROLS
# =========================

$lblFirstName = New-Object System.Windows.Forms.Label
$lblFirstName.Text = "First Name:"
$lblFirstName.Location = New-Object System.Drawing.Point(20,20)
$txtFirstName = New-Object System.Windows.Forms.TextBox
$txtFirstName.Location = New-Object System.Drawing.Point(150,18)
$txtFirstName.Width = 200

$lblLastName = New-Object System.Windows.Forms.Label
$lblLastName.Text = "Last Name:"
$lblLastName.Location = New-Object System.Drawing.Point(20,50)
$txtLastName = New-Object System.Windows.Forms.TextBox
$txtLastName.Location = New-Object System.Drawing.Point(150,48)
$txtLastName.Width = 200

$lblSam = New-Object System.Windows.Forms.Label
$lblSam.Text = "samAccountName:"
$lblSam.Location = New-Object System.Drawing.Point(20,80)
$txtSam = New-Object System.Windows.Forms.TextBox
$txtSam.Location = New-Object System.Drawing.Point(150,78)
$txtSam.Width = 150

$btnAutoSam = New-Object System.Windows.Forms.Button
$btnAutoSam.Text = "Auto-Generate"
$btnAutoSam.Location = New-Object System.Drawing.Point(310,76)
$btnAutoSam.Add_Click({
    if ($txtFirstName.Text -and $txtLastName.Text) {
        $txtSam.Text = ($txtFirstName.Text.Substring(0,1) + $txtLastName.Text).ToLower()
    }
})

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Title:"
$lblTitle.Location = New-Object System.Drawing.Point(20,110)
$txtTitle = New-Object System.Windows.Forms.TextBox
$txtTitle.Location = New-Object System.Drawing.Point(150,108)
$txtTitle.Width = 200

$lblDept = New-Object System.Windows.Forms.Label
$lblDept.Text = "Department:"
$lblDept.Location = New-Object System.Drawing.Point(20,140)
$cmbDept = New-Object System.Windows.Forms.ComboBox
$cmbDept.Location = New-Object System.Drawing.Point(150,138)
$cmbDept.Width = 200
$cmbDept.DropDownStyle = 'DropDownList'
$cmbDept.Items.AddRange(@("IT","Finance","HR","Clinical","Operations"))

$lblEmpType = New-Object System.Windows.Forms.Label
$lblEmpType.Text = "Employee Type:"
$lblEmpType.Location = New-Object System.Drawing.Point(20,170)
$cmbEmpType = New-Object System.Windows.Forms.ComboBox
$cmbEmpType.Location = New-Object System.Drawing.Point(150,168)
$cmbEmpType.Width = 200
$cmbEmpType.DropDownStyle = 'DropDownList'
$cmbEmpType.Items.AddRange(@("FTE","NFTE","Contractor","Temp"))

$lblStartDate = New-Object System.Windows.Forms.Label
$lblStartDate.Text = "Start Date:"
$lblStartDate.Location = New-Object System.Drawing.Point(20,200)
$dtpStart = New-Object System.Windows.Forms.DateTimePicker
$dtpStart.Location = New-Object System.Drawing.Point(150,198)
$dtpStart.Width = 200

$lblMgrId = New-Object System.Windows.Forms.Label
$lblMgrId.Text = "Manager EmployeeID:"
$lblMgrId.Location = New-Object System.Drawing.Point(20,230)
$txtMgrId = New-Object System.Windows.Forms.TextBox
$txtMgrId.Location = New-Object System.Drawing.Point(150,228)
$txtMgrId.Width = 200

$lblTemplate = New-Object System.Windows.Forms.Label
$lblTemplate.Text = "Template:"
$lblTemplate.Location = New-Object System.Drawing.Point(20,260)
$cmbTemplate = New-Object System.Windows.Forms.ComboBox
$cmbTemplate.Location = New-Object System.Drawing.Point(150,258)
$cmbTemplate.Width = 200
$cmbTemplate.DropDownStyle = 'DropDownList'
$cmbTemplate.Items.AddRange(@("TestDomainTemplate","TestDomainTemplateNFTE")

$lblPwd = New-Object System.Windows.Forms.Label
$lblPwd.Text = "Temporary Password:"
$lblPwd.Location = New-Object System.Drawing.Point(20,290)
$txtPwd = New-Object System.Windows.Forms.TextBox
$txtPwd.Location = New-Object System.Drawing.Point(150,288)
$txtPwd.Width = 200
$txtPwd.UseSystemPasswordChar = $true

$btnCreateUser = New-Object System.Windows.Forms.Button
$btnCreateUser.Text = "Create AD User"
$btnCreateUser.Location = New-Object System.Drawing.Point(20,330)

$btnApplyAttributes = New-Object System.Windows.Forms.Button
$btnApplyAttributes.Text = "Apply Attributes"
$btnApplyAttributes.Location = New-Object System.Drawing.Point(150,330)

$btnNextToMailbox = New-Object System.Windows.Forms.Button
$btnNextToMailbox.Text = "Next → Mailbox"
$btnNextToMailbox.Location = New-Object System.Drawing.Point(280,330)

$txtUserOutput = New-Object System.Windows.Forms.TextBox
$txtUserOutput.Location = New-Object System.Drawing.Point(400,20)
$txtUserOutput.Size = New-Object System.Drawing.Size(360,300)
$txtUserOutput.Multiline = $true
$txtUserOutput.ScrollBars = 'Vertical'
$txtUserOutput.ReadOnly = $true

$btnClearUserOutput = New-Object System.Windows.Forms.Button
$btnClearUserOutput.Text = "Clear Output"
$btnClearUserOutput.Location = New-Object System.Drawing.Point(400,330)
$btnClearUserOutput.Add_Click({ $txtUserOutput.Clear() })

$tabUserInfo.Controls.AddRange(@(
    $lblFirstName,$txtFirstName,
    $lblLastName,$txtLastName,
    $lblSam,$txtSam,$btnAutoSam,
    $lblTitle,$txtTitle,
    $lblDept,$cmbDept,
    $lblEmpType,$cmbEmpType,
    $lblStartDate,$dtpStart,
    $lblMgrId,$txtMgrId,
    $lblTemplate,$cmbTemplate,
    $lblPwd,$txtPwd,
    $btnCreateUser,
    $btnApplyAttributes,
    $btnNextToMailbox,
    $txtUserOutput,
    $btnClearUserOutput
))

# =========================
# MAILBOX TAB CONTROLS
# =========================

$lblMbxSam = New-Object System.Windows.Forms.Label
$lblMbxSam.Text = "samAccountName:"
$lblMbxSam.Location = New-Object System.Drawing.Point(20,20)
$txtMbxSam = New-Object System.Windows.Forms.TextBox
$txtMbxSam.Location = New-Object System.Drawing.Point(150,18)
$txtMbxSam.Width = 200

$lblPrimary = New-Object System.Windows.Forms.Label
$lblPrimary.Text = "Primary SMTP:"
$lblPrimary.Location = New-Object System.Drawing.Point(20,50)
$txtPrimary = New-Object System.Windows.Forms.TextBox
$txtPrimary.Location = New-Object System.Drawing.Point(150,48)
$txtPrimary.Width = 300

$lblRemote = New-Object System.Windows.Forms.Label
$lblRemote.Text = "Remote Routing:"
$lblRemote.Location = New-Object System.Drawing.Point(20,80)
$txtRemote = New-Object System.Windows.Forms.TextBox
$txtRemote.Location = New-Object System.Drawing.Point(150,78)
$txtRemote.Width = 300

$btnGenMail = New-Object System.Windows.Forms.Button
$btnGenMail.Text = "Generate Addresses"
$btnGenMail.Location = New-Object System.Drawing.Point(150,110)
$btnGenMail.Add_Click({
    if ($txtMbxSam.Text) {
        $txtPrimary.Text = "$($txtMbxSam.Text)@TestDomain.com"
        $txtRemote.Text  = "$($txtMbxSam.Text)@TestDomain2.mail.onmicrosoft.com"
    }
})

$btnCreateMbx = New-Object System.Windows.Forms.Button
$btnCreateMbx.Text = "Create Remote Mailbox"
$btnCreateMbx.Location = New-Object System.Drawing.Point(20,150)

$btnValidateMbx = New-Object System.Windows.Forms.Button
$btnValidateMbx.Text = "Validate Mailbox"
$btnValidateMbx.Location = New-Object System.Drawing.Point(20,180)

$txtMbxOutput = New-Object System.Windows.Forms.TextBox
$txtMbxOutput.Location = New-Object System.Drawing.Point(400,20)
$txtMbxOutput.Size = New-Object System.Drawing.Size(360,300)
$txtMbxOutput.Multiline = $true
$txtMbxOutput.ScrollBars = 'Vertical'
$txtMbxOutput.ReadOnly = $true

$btnClearMbxOutput = New-Object System.Windows.Forms.Button
$btnClearMbxOutput.Text = "Clear Output"
$btnClearMbxOutput.Location = New-Object System.Drawing.Point(400,330)
$btnClearMbxOutput.Add_Click({ $txtMbxOutput.Clear() })

$tabMailbox.Controls.AddRange(@(
    $lblMbxSam,$txtMbxSam,
    $lblPrimary,$txtPrimary,
    $lblRemote,$txtRemote,
    $btnGenMail,
    $btnCreateMbx,
    $btnValidateMbx,
    $txtMbxOutput,
    $btnClearMbxOutput
))

# =========================
# BULK TAB CONTROLS
# =========================

$lblCsv = New-Object System.Windows.Forms.Label
$lblCsv.Text = "CSV File:"
$lblCsv.Location = New-Object System.Drawing.Point(20,20)
$txtCsv = New-Object System.Windows.Forms.TextBox
$txtCsv.Location = New-Object System.Drawing.Point(80,18)
$txtCsv.Width = 400

$btnBrowseCsv = New-Object System.Windows.Forms.Button
$btnBrowseCsv.Text = "Browse"
$btnBrowseCsv.Location = New-Object System.Drawing.Point(490,16)

$openFile = New-Object System.Windows.Forms.OpenFileDialog
$openFile.Filter = "CSV Files (*.csv)|*.csv|All Files (*.*)|*.*"

$btnBrowseCsv.Add_Click({
    if ($openFile.ShowDialog() -eq 'OK') {
        $txtCsv.Text = $openFile.FileName
    }
})

$btnRunBulk = New-Object System.Windows.Forms.Button
$btnRunBulk.Text = "Run Bulk Onboarding"
$btnRunBulk.Location = New-Object System.Drawing.Point(20,60)

$txtBulkOutput = New-Object System.Windows.Forms.TextBox
$txtBulkOutput.Location = New-Object System.Drawing.Point(20,100)
$txtBulkOutput.Size = New-Object System.Drawing.Size(740,350)
$txtBulkOutput.Multiline = $true
$txtBulkOutput.ScrollBars = 'Vertical'
$txtBulkOutput.ReadOnly = $true

$btnRunBulk.Add_Click({
    $msg = Run-TestDomainBulkOnboarding -CsvPath $txtCsv.Text
    $txtBulkOutput.AppendText("$msg`r`n")
})

$btnClearBulkOutput = New-Object System.Windows.Forms.Button
$btnClearBulkOutput.Text = "Clear Output"
$btnClearBulkOutput.Location = New-Object System.Drawing.Point(650,460)
$btnClearBulkOutput.Add_Click({ $txtBulkOutput.Clear() })

$tabBulk.Controls.AddRange(@(
    $lblCsv,$txtCsv,$btnBrowseCsv,
    $btnRunBulk,
    $txtBulkOutput,
    $btnClearBulkOutput
))

# =========================
# LOGS TAB
# =========================

$lblLogsInfo = New-Object System.Windows.Forms.Label
$lblLogsInfo.Text = "Log file: $Global:LogFile"
$lblLogsInfo.Location = New-Object System.Drawing.Point(20,20)
$lblLogsInfo.AutoSize = $true

$txtLogsView = New-Object System.Windows.Forms.TextBox
$txtLogsView.Location = New-Object System.Drawing.Point(20,50)
$txtLogsView.Size = New-Object System.Drawing.Size(740,400)
$txtLogsView.Multiline = $true
$txtLogsView.ScrollBars = 'Vertical'
$txtLogsView.ReadOnly = $true

$btnRefreshLogs = New-Object System.Windows.Forms.Button
$btnRefreshLogs.Text = "Refresh Logs"
$btnRefreshLogs.Location = New-Object System.Drawing.Point(20,460)
$btnRefreshLogs.Add_Click({
    if (Test-Path $Global:LogFile) {
        $txtLogsView.Text = Get-Content $Global:LogFile -Raw
    }
    else {
        $txtLogsView.Text = "No log file found for today."
    }
})

$tabLogs.Controls.AddRange(@(
    $lblLogsInfo,
    $txtLogsView,
    $btnRefreshLogs
))

# =========================
# WORKFLOW ENFORCEMENT
# =========================

$btnApplyAttributes.Enabled = $false
$btnNextToMailbox.Enabled   = $false
$btnCreateMbx.Enabled       = $false
$btnValidateMbx.Enabled     = $false

$btnCreateUser.Add_Click({
    $securePwd = ConvertTo-SecureString $txtPwd.Text -AsPlainText -Force

    $msg = New-TestDomainUser -FirstName $txtFirstName.Text `
                          -LastName $txtLastName.Text `
                          -Sam $txtSam.Text `
                          -Title $txtTitle.Text `
                          -Department $cmbDept.Text `
                          -EmployeeType $cmbEmpType.Text `
                          -StartDate $dtpStart.Value `
                          -Template $cmbTemplate.Text `
                          -Password $securePwd

    $txtUserOutput.AppendText("$msg`r`n")

    if ($msg -like "*Created AD user*") {
        $btnApplyAttributes.Enabled = $true
    }
})

$btnApplyAttributes.Add_Click({
    $ext = @{
        extensionAttribute1 = ($txtFirstName.Text + " " + $txtLastName.Text).ToUpper()
        extensionAttribute2 = $txtMgrId.Text
        extensionAttribute15 = $cmbEmpType.Text
    }

    $msg1 = Set-TestDomainAttributes -Sam $txtSam.Text `
                                 -ExtensionAttributes $ext `
                                 -Title $txtTitle.Text `
                                 -Department $cmbDept.Text `
                                 -StreetAddress "Offsite"

    $txtUserOutput.AppendText("$msg1`r`n")

    $msg2 = Set-TestDomainManager -Sam $txtSam.Text -ManagerEmployeeId $txtMgrId.Text
    $txtUserOutput.AppendText("$msg2`r`n")

    if ($msg1 -like "*Applied attributes*" -or $msg2 -like "*Manager*") {
        $btnNextToMailbox.Enabled = $true
    }
})

$btnNextToMailbox.Add_Click({
    $tabControl.SelectedTab = $tabMailbox
    $txtMbxSam.Text = $txtSam.Text
    $txtPrimary.Text = "$($txtSam.Text)@TestDomain.com"
    $txtRemote.Text  = "$($txtSam.Text)@TestDomain2.mail.onmicrosoft.com"
    $btnCreateMbx.Enabled = $true
})

$btnCreateMbx.Add_Click({
    $msg = Enable-TestDomainRemoteMailbox -Sam $txtMbxSam.Text `
                                      -PrimarySmtp $txtPrimary.Text `
                                      -RemoteRouting $txtRemote.Text

    $txtMbxOutput.AppendText("$msg`r`n")

    if ($msg -like "*Remote mailbox created*") {
        $btnValidateMbx.Enabled = $true
    }
})

$btnValidateMbx.Add_Click({
    $msg = Validate-TestDomainMailbox -Sam $txtMbxSam.Text
    $txtMbxOutput.AppendText("$msg`r`n")
})

# =========================
# RUN FORM
# =========================

[void]$form.ShowDialog()
