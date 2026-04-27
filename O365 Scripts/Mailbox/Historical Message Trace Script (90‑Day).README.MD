Overview

This PowerShell script automates the process of submitting a Historical Message Trace request in Exchange Online. Historical traces allow administrators to retrieve message‑level metadata for up to 90 days in the past, which is essential for investigations, compliance reviews, and delivery troubleshooting.
The script prompts the operator for the target mailbox or distribution list, validates date ranges, enforces the 90‑day limit, submits the historical trace job, and logs job details to a timestamped CSV file for tracking.
It is designed for administrators working in Exchange Online or hybrid Exchange environments.

What This Script Does
For each run, the script performs the following automated tasks:
• 	Prompts for:
• 	Recipient email address (mailbox or DL)
• 	Start date
• 	End date
• 	Validates date formatting (YYYY‑MM‑DD)
• 	Ensures the date range does not exceed 90 days
• 	Submits a Start-HistoricalSearch job with:
• 	Report title
• 	Date range
• 	Recipient address
• 	Report type (MessageTrace)
• 	Generates a timestamped CSV log file containing:
• 	Job ID
• 	Submission details
• 	Displays instructions for:
• 	Checking job status
• 	Downloading the completed report from the Exchange Admin Center

This script simplifies a multi‑step administrative workflow into a guided, error‑resistant process.

Environment Requirements
This script is intended for use in: Exchange Online PowerShell
You must be connected using:
• 	Exchange Online PowerShell v2 (EXO V2) module



How to Run

1. 	Open Exchange Online PowerShell or Exchange Management Shell
2. 	Navigate to the folder containing the script
3. 	Run: .\HistoricalMessageTrace.ps1
4. 	Enter:
• 	Email address
• 	Start date
• 	End date
5. 	The script will:
• 	Validate inputs
• 	Submit the trace
• 	Save job details
• 	Display next steps

CSV Output- HistoricalTraceJob_YYYYMMDD_HHMMSS.csv

The script automatically generates a log file in the same directory:

This file contains:
• 	Job ID
• 	Report title
• 	Submission timestamps
• 	Recipient address
• 	Date range

This ensures trace jobs can be tracked, audited, and referenced later.

Why This Script Is Useful

Running historical message traces manually requires multiple steps:
• 	Validating date ranges
• 	Ensuring the 90‑day limit
• 	Submitting the job
• 	Tracking the Job ID
• 	Recording job metadata

This script eliminates errors and standardizes the process, making it ideal for:
• 	Messaging administrators
• 	Security teams
• 	Compliance investigations
• 	Helpdesk escalations

It ensures consistent, repeatable, and auditable trace submissions.

Customization

You may modify:
• 	Default date formats
• 	Output folder location
• 	Report naming conventions
• 	Additional parameters for 
• 	Logging behavior

The script is intentionally simple and modular to support easy adaptation.

Important Notes
• 	Historical message trace does not return message content — only metadata
• 	Reports must be downloaded from the Exchange Admin Center once complete
• 	Job completion time varies depending on:
• 	Date range
• 	Recipient volume
• 	Microsoft 365 load
