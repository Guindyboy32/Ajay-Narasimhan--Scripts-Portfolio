# Import users from CSV
$users = Import-Csv -Path "C:\MSP\users.csv"

foreach ($user in $users) {
    $Username = $user.Username
    $Password = ConvertTo-SecureString $user.Password -AsPlainText -Force
    $DisplayName = $user.DisplayName
    $OU = $user.OU
    $Email = $user.Email
    $Department = $user.Department
    $Title = $user.Title
    $HomeDirectory = $user.HomeDirectory
    $Groups = $user.Groups -split ','

    # Create the user
    New-ADUser -Name $Username -AccountPassword $Password -PasswordNeverExpires $true -Enabled $true -DisplayName $DisplayName -Path $OU -UserPrincipalName "$Username@example.com" -SamAccountName $Username -EmailAddress $Email -Department $Department -Title $Title -HomeDirectory $HomeDirectory -HomeDrive "H:"

    # Add user to specified groups
    foreach ($group in $Groups) {
        Add-ADGroupMember -Identity $group -Members $Username
    }
    Write-Output "Created user account for $Username and added to specified groups."
}
