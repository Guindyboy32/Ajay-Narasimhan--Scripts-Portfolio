# Variables
$groupName = "ITAdmins"
$reportPath = "C:\\GroupMembershipReport.csv"
$smtpServer = "smtp.domain.com"
$from = "no-reply@domain.com"
$to = "admin@domain.com"

# Get Current Group Members
$currentMembers = Get-ADGroupMember -Identity $groupName | Select-Object Name, SamAccountName

# Compare with Previous Members (if report exists)
if (Test-Path $reportPath) {
    $previousMembers = Import-Csv -Path $reportPath
    $addedMembers = Compare-Object -ReferenceObject $previousMembers -DifferenceObject $currentMembers -Property SamAccountName -PassThru | Where-Object { $_.SideIndicator -eq "=>" }
    $removedMembers = Compare-Object -ReferenceObject $previousMembers -DifferenceObject $currentMembers -Property SamAccountName -PassThru | Where-Object { $_.SideIndicator -eq "<=" }

    # Prepare Email Report
    $emailBody = "Group: $groupName`n`n"
    $emailBody += "Added Members:`n" + ($addedMembers | Format-Table -AutoSize | Out-String) + "`n"
    $emailBody += "Removed Members:`n" + ($removedMembers | Format-Table -AutoSize | Out-String)
    
    # Send Email
    Send-MailMessage -SmtpServer $smtpServer -From $from -To $to -Subject "AD Group Membership Report" -Body $emailBody
}

# Save Current Members for Future Comparison
$currentMembers | Export-Csv -Path $reportPath -NoTypeInformation
