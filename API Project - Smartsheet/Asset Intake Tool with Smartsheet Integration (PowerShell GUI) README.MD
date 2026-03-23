# Asset Intake Tool with Smartsheet Integration (PowerShell GUI)

This project is a fully interactive Windows Forms application built in PowerShell that captures device asset information and synchronizes it with Smartsheet. It supports both **creating new rows** and **updating existing rows**, making it a complete CRUD‑style asset management tool.

The tool is designed for Service Desk, imaging teams, and asset managers who need a fast, reliable, and user‑friendly way to record device information during provisioning or hardware refresh workflows.

--- Overview

This tool provides:

- A clean GUI for entering Asset Tag, Serial Number, and Model  
- Automatic hardware detection via WMI  
- A dropdown list of Smartsheet sheets (pulled dynamically via API)  
- Logic to **create** a new row if the asset does not exist  
- Logic to **update** an existing row if the asset already exists  
- Local CSV + JSON logging for redundancy  
- Error logging for troubleshooting  
- A workflow optimized for **multiple entries** (form stays open)

This is an enterprise‑grade automation tool suitable for real production environments.

--- Features

Windows Forms GUI  
A simple, intuitive interface that non‑technical staff can use.

Auto‑populate hardware details  
- Serial Number → from `Win32_BIOS`  
- Model → from `Win32_ComputerSystem`  

Smartsheet sheet selection  
- Dropdown automatically populated from the Smartsheet API  
- User selects which sheet to write to  
- Supports multiple departments or workflows

Create or Update logic  
The tool checks Smartsheet for an existing Asset Tag:

- **If found:** updates the existing row  
- **If not found:** creates a new row  

This ensures clean, deduplicated asset records.

Local CSV + JSON export  
All entries are saved locally to: C:\Temp\AssetTool\AssetCapture.csv C:\Temp\AssetTool\AssetCapture.json


Error logging  
All API or WMI errors are logged to:


C:\Temp\AssetTool\AssetTool.log

Clear button  
Resets the form for rapid multi‑device entry.

GUI Layout

The form includes:

- **Asset Tag** (manual entry)  
- **Serial Number** (auto‑populated)  
- **Model** (auto‑populated)  
- **Smartsheet dropdown** (auto‑populated)  
- **Submit** button  
- **Clear** button  
- **Status label**  

This layout is optimized for imaging benches and asset intake stations.

---

Requirements

To run this tool, you need:

- Windows PowerShell 5.1 or PowerShell 7+  
- .NET Windows Forms support  
- Internet access to Smartsheet  
- A Smartsheet API token  
- Column IDs for:
  - Asset Tag  
  - Serial  
  - Model  
  - Timestamp  

These must be configured in the script.

---Usage

1. Insert your Smartsheet API token into the script.
2. Insert your column IDs for the target sheet(s).
3. Run the script:

```powershell
.\AssetTool-Smartsheet.ps1


- Select a Smartsheet sheet from the dropdown.
- Enter or verify the asset fields.
- Click Submit:
- If the Asset Tag exists → row is updated
- If not → new row is created
- Click Clear to prepare for the next device.


JSON Example{
  "AssetTag": "ABC123",
  "Serial": "12345XYZ",
  "Model": "Latitude 7420",
  "Timestamp": "2026-03-23T12:34:00"
}


