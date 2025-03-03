# Variables
$csvPath = "C:\\UserChanges.csv"

# Import CSV and Update Group Membership
Import-Csv -Path $csvPath | ForEach-Object {
    $user = Get-ADUser -Identity $_.SamAccountName -Properties Department
    if ($user.Department -ne $_.NewDepartment) {
        # Remove from Old Department Group
        Remove-ADGroupMember -Identity "$($user.Department)Group" -Members $user.SamAccountName -Confirm:$false

        # Add to New Department Group
        Add-ADGroupMember -Identity "$($_.NewDepartment)Group" -Members $user.SamAccountName

        # Update User Department
        Set-ADUser -Identity $user.SamAccountName -Department $_.NewDepartment
    }
}
