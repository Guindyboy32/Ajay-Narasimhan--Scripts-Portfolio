# Asset Tag Entry Tool (PowerShell GUI)

This project is a lightweight Windows Forms application built in PowerShell that provides a simple, user‑friendly interface for capturing device asset information. It is ideal for IT technicians, imaging teams, and asset management workflows where quick and accurate data entry is required.

The tool automatically retrieves hardware details, validates user input, and saves the captured data to both CSV and JSON formats for easy reporting or integration with other systems.

---

## Overview

This tool allows technicians to quickly enter or verify device information using a clean graphical interface. It automatically pulls hardware details from WMI and stores the results locally for tracking or import into asset management systems.

---

## Features

### ✔ Windows Forms GUI  
A simple, intuitive interface that non‑technical staff can use.

### ✔ Auto‑populate hardware details  
- **Serial Number** is retrieved from `Win32_BIOS`  
- **Model** is retrieved from `Win32_ComputerSystem`  

### ✔ Required‑field validation  
The form prevents submission if any field is empty, ensuring clean and complete data.

### ✔ Save to CSV and JSON  
Captured data is saved to:

C:\Temp\AssetCapture.csv C:\Temp\AssetCapture.json

The folder is created automatically if it doesn’t exist.

### ✔ Submit & Close workflow  
After saving the data, the form closes automatically.

### ✔ Clear button  
Instantly resets all fields for rapid multi‑device entry.

---

## GUI Layout

The form includes:

- **Asset Tag** (manual entry)  
- **Serial Number** (auto‑populated)  
- **Model** (auto‑populated)  
- **Submit** button  
- **Clear** button  

This layout is optimized for imaging benches and asset intake stations.

---Usage

1. Run the script in PowerShell:

```powershell
.\AssetTagEntry.ps1


- The GUI will appear automatically.
- Enter or verify the fields:
- Asset Tag (required)
- Serial Number (auto-filled)
- Model (auto-filled)
- Click Submit to save the data and close the form.
- Or click Clear to reset all fields.


JSON Example
{
  "AssetTag": "ABC123",
  "Serial": "12345XYZ",
  "Model": "Latitude 7420",
  "Timestamp": "2026-03-23T12:34:00"
}


Why This Tool Exists
IT teams often need a fast, reliable way to capture device information during:
- Imaging and provisioning
- Hardware refresh cycles
- Break/fix repairs
- Asset tagging
- Autopilot pre‑stage workflows
This tool eliminates manual typing errors, speeds up intake, and ensures consistent data formatting.


