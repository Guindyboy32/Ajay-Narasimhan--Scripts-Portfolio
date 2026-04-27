Overview
This PowerShell script automates running a Get‑MessageTraceV2 query in Exchange Online.
Because standard message trace only supports a maximum 10‑day range, the script validates the date window, runs the trace, and exports results to a timestamped CSV file.
This tool is ideal for administrators who need quick, repeatable message‑level visibility for troubleshooting, delivery validation, or user‑reported mail flow issues.

What This Script Does
Each time the script runs, it performs the following:
• 	Prompts for:
• 	Recipient email address
• 	Start date
• 	End date
• 	Validates date formatting (YYYY‑MM‑DD)
• 	Enforces the 10‑day limit required by Get‑MessageTraceV2
• 	Determines the script directory automatically
• 	Generates a timestamped CSV log file
• 	Runs Get‑MessageTraceV2 with the provided parameters
• 	Saves results to CSV or logs “no results found”

This ensures consistent, error‑free message trace execution.

Environment Requirements
This script is intended for use in:
Exchange Online PowerShell
You must be connected using:
• 	Exchange Online PowerShell v2 (EXO V2) module
or
• 	Exchange Management Shell in a hybrid environment
Required Permissions
You must have rights to:
• 	Run Get‑MessageTraceV2
• 	Access message trace data
• 	Export CSV files to the script directory


How to Run
- Open Exchange Online PowerShell or Exchange Management Shell
- Navigate to the folder containing the script
- Run: .\MessageTrace10Day.ps1
- Enter:
• 	Email address
• 	Start date
• 	End date

- The script will:
• 	Validate the date range
• 	Run the trace
• 	Save results to a CSV file

CSV OutputThe script automatically generates a log file in the same directory:MessageTraceLog_YYYYMMDD_HHMMSS.csv

This file contains:
• 	Message trace results (if found)
• 	Or a note indicating no results were returned
This ensures all trace attempts are documented for auditing and follow‑up.
                           
Why This Script Is Useful
                           
Running message traces manually requires multiple steps:
• 	Checking date range limits
• 	Running the trace
• 	Exporting results
• 	Logging output
                           
This script simplifies the process and ensures:
• 	No invalid date ranges
• 	Consistent output formatting
• 	Automatic logging
• 	Faster troubleshooting
                           
It’s especially useful for:
• 	Helpdesk escalations
• 	Mail flow investigations
• 	User‑reported delivery issues
• 	Daily operational checks

Customization
You may modify:
• 	Default output folder
• 	File naming conventions
• 	Additional filtering parameters
• 	Output formatting
• 	Logging behavior
                           
The script is intentionally lightweight and easy to extend.

Important Notes
• 	Get‑MessageTraceV2 only supports a 10‑day window
• 	For older data (up to 90 days), use Start‑HistoricalSearch instead
• 	Message trace returns metadata only — not message content
• 	Large date ranges or high‑volume recipients may take longer to return results
