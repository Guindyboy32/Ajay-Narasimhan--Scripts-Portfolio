A lightweight but production‑ready PowerShell WinForms application for capturing asset information during device intake.
Designed for IT technicians, MSPs, and enterprise hardware workflows.

This tool provides a simple GUI for entering an Asset Tag, while automatically collecting the device’s Serial Number and Model via WMI.
Captured data is written to both CSV and JSON formats, along with a full audit log.

Features
✔ Modern, user‑friendly GUI
Built with Windows Forms for fast technician workflows.

✔ Automatic hardware detection
- Serial Number → via Win32_BIOS
- Model → via Win32_ComputerSystem

No manual typing required.
✔ Input validation
Ensures all fields are completed before saving.

✔ Structured output
Data is saved to:
- AssetCapture.csv — Excel‑friendly
- AssetCapture.json — structured, machine‑readable
- AssetTool.log — timestamped audit log

✔ Enterprise‑grade architecture
- Modular functions
- Centralized logging
- Error handling
- Configurable output paths
- Clean separation of concerns
- Extensible design for future integrations (Snipe‑IT, Smartsheet, etc.)

Output Files
All files are written to:
C:\Temp\AssetTool\
Generated files include:
File                    Purpose
AssetCapture.csv        Append‑only CSV log of all captured assets
AssetCapture.json       JSON log for automation pipelines
AssetTool.log           Timestamped operational log

 How It Works
- Launch the script (AssetCapture.ps1)
- The GUI opens with three fields:
- Asset Tag (manual)
- Serial Number (auto‑populated)
- Model (auto‑populated)
- Technician enters the Asset Tag
- Click Submit
- Data is validated, logged, and saved locally
- Form closes automatically

A Clear button resets the form and re‑populates hardware info.

 Requirements
- Windows 10/11
- PowerShell 5.1+
- .NET Framework (WinForms support)
No external modules required.

Code Structure
The script is organized into clean, maintainable sections:
Add-Type (WinForms)
Configuration
Logging helpers
WMI helpers
Save‑data function
GUI construction
Submit logic
Clear logic


This structure makes the tool easy to extend with:
- API integrations
- Barcode scanning
- Technician authentication
- Cloud syncing
- Snipe‑IT or Smartsheet automation

Extending the Tool
This project is intentionally designed to be extensible.
Common enhancements include:
- Push captured assets directly into Snipe‑IT
- Create/update rows in Smartsheet
- Add barcode scanner input
- Add dropdowns for model types or locations
- Package as a standalone EXE using PS2EXE
- Add technician ID tracking
If you plan to integrate this with your Snipe‑IT or Smartsheet automation, the architecture already supports it.

📄 License
MIT License (or whatever you choose).
