# Connect to SharePoint Online
Connect-SPOService -Url https://yourdomain-admin.sharepoint.com

# Get all OneDrive sites
Get-SPOSite -Template "SPSPERS" | Select-Object Url, Owner
