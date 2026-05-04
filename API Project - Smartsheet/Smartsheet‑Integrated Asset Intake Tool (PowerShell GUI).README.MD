A production‑ready PowerShell WinForms application that allows IT technicians to capture asset information and automatically sync it with Smartsheet.
The tool supports create‑or‑update logic, local logging, CSV/JSON export, and dynamic sheet selection from the Smartsheet API.
This project is designed for enterprise hardware intake, MSP workflows, and IT asset lifecycle management.

Features
Smartsheet API Integration
- Retrieves available sheets dynamically
- Creates new rows or updates existing ones
- Uses column IDs for precise cell mapping
- Handles API errors gracefully with user alerts and log entries

Automatic Hardware Detection
- Serial Number → via Win32_BIOS
- Model → via Win32_ComputerSystem
- Reduces technician typing and errors

Intelligent Create/Update Logic
The tool checks Smartsheet for an existing row matching the Asset Tag:
- If found → updates the row
- If not found → creates a new row
This prevents duplicates and ensures clean data.

Local Data Persistence
All captured assets are saved locally to:
- AssetCapture.csv
- AssetCapture.json
- AssetTool.log
Perfect for offline backup, reconciliation, and audits.

Technician‑Friendly GUI
- Clean WinForms interface
- Auto‑population of hardware info
- Dropdown for selecting Smartsheet
- Status messages for each operation
- Clear button resets the form for the next device

Output Files
All files are written to:
C:\Temp\AssetTool\

File                   Purpose  
AssetCapture.csv       Append‑only CSV log of all captured assets
AssetCapture.json      JSON log for automation pipelines
AssetTool.log          Timestamped operational log


Architecture Overview
The script is structured into clean, maintainable sections:
1. Configuration
- Smartsheet API token
- Base URL
- Column IDs
- Output paths

2. Logging Helper
Centralized logging with timestamps.

3. Smartsheet API Wrapper
Handles:
- GET, POST, PUT
- JSON serialization
- Error handling
- User alerts

4. GUI Construction
- Labels
- Textboxes
- Dropdown
- Buttons
- Status label

5. Local Save Logic
Writes CSV + JSON for each asset.

6. Smartsheet Row Lookup
Searches for existing rows by Asset Tag.

7. Submit Logic
- Validates input
- Checks Smartsheet for existing row
- Updates or creates accordingly
- Saves locally
- Logs all actions

8. Clear Logic
Resets form and re‑populates hardware info.

Requirements
- Windows 10/11
- PowerShell 5.1+
- .NET Framework (WinForms support)
- Smartsheet API token
- Valid column IDs in your Smartsheet

Running the Tool
- Insert your Smartsheet API token:
$SmartsheetToken = "<YOUR_SMARTSHEET_API_TOKEN_HERE>"


- Update the column IDs to match your Smartsheet:
$AssetTagColumnId = 1111111111111111
$SerialColumnId   = 2222222222222222
$ModelColumnId    = 3333333333333333
$TimestampColumnId= 4444444444444444


- Run the script:
.\AssetTool-Smartsheet.ps1


- Select a Smartsheet from the dropdown
- Enter the Asset Tag
- Click Submit
- Data is saved locally and synced to Smartsheet

ExtensibilityThis tool is designed to be extended.
Common enhancements include:
- Snipe‑IT asset creation
- Barcode scanner input
- Technician login tracking
- Dropdowns for model/location
- Packaging as a standalone EXE
- Adding retry logic for Smartsheet rate limits
- Multi‑sheet routing based on model or location
