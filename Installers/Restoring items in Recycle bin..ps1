# Load the necessary .NET assembly
Add-Type -AssemblyName Microsoft.VisualBasic

# Restore all items in the Recycle Bin
[Microsoft.VisualBasic.FileIO.FileSystem]::GetRecycleBinItems() | ForEach-Object { 
    [Microsoft.VisualBasic.FileIO.FileSystem]::RestoreFromRecycleBin($_) 
}

Write-Host "All items have been restored from the Recycle Bin."
