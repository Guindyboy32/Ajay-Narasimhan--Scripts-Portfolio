Connect-MicrosoftTeams

# Import CSV
$rows = Import-Csv "C:\Scripts\TeamUsers.csv"

foreach ($row in $rows) {

    $UserUPN = $row.UserUPN
    $TeamName = $row.TeamName
    $PrivateChannels = $row.PrivateChannels -split ";"

    # Get the team
    $team = Get-Team -DisplayName $TeamName
    if (-not $team) {
        Write-Host "Team '$TeamName' not found." -ForegroundColor Red
        continue
    }

    $GroupId = $team.GroupId

    # Add user to team if needed
    $teamUsers = Get-TeamUser -GroupId $GroupId
    if ($teamUsers.User -notcontains $UserUPN) {
        Write-Host "Adding $UserUPN to team '$TeamName'..."
        Add-TeamUser -GroupId $GroupId -User $UserUPN
    }

    # Get channels
    $channels = Get-TeamChannel -GroupId $GroupId

    # Add user to private channels
    foreach ($channelName in $PrivateChannels) {

        $channel = $channels | Where-Object {
            $_.DisplayName -eq $channelName -and $_.MembershipType -eq "Private"
        }

        if (-not $channel) {
            Write-Host "Private channel '$channelName' not found in team '$TeamName'." -ForegroundColor Yellow
            continue
        }

        Write-Host "Adding $UserUPN to private channel '$channelName'..."
        Add-TeamChannelUser -GroupId $GroupId -DisplayName $channelName -User $UserUPN
    }
}

Write-Host "Processing complete." -ForegroundColor Green
