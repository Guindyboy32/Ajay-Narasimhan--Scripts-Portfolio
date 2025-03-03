# Define distribution group and users
$DistributionGroup = "distributiongroup@yourdomain.com"
$Users = @("user1@yourdomain.com", "user2@yourdomain.com")

# Add users to the distribution group
foreach ($User in $Users) {
    Add-DistributionGroupMember -Identity $DistributionGroup -Member $User
}
