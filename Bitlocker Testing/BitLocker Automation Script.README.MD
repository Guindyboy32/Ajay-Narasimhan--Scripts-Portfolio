Overview
This script automates the process of enabling BitLocker encryption on both local and remote Windows machines, while securely storing recovery keys in a centralized location. It is designed for administrators who need a consistent, repeatable, and auditable way to enforce disk encryption across an environment.

  The script supports:
- Local BitLocker enablement
- Remote BitLocker enablement via PowerShell Remoting
- Centralized recovery key storage (local folder or network share)
- Optional email notifications when encryption is enabled
- Logging and validation for safer execution

This makes it suitable for MSPs, enterprise IT teams, and security‑focused environments where encryption compliance is required.

Key Features

1. Local BitLocker Enablement
The script checks whether BitLocker is already enabled on the specified drive.
If not, it:
- Enables BitLocker using TPM protector
- Uses AES‑256 encryption
- Encrypts used space only for faster deployment
- Saves the recovery key to a secure local directory

 2. Remote BitLocker Enablement
The script reads a list of machine names from a text file and performs the same encryption workflow remotely using Invoke-Command.
For each remote machine, it:
- Validates BitLocker status
- Enables encryption if needed
- Stores the recovery key in a central network share
- Logs the result for each machine

 3. Optional Email Notifications
If enabled, the script sends an email notification when BitLocker is successfully enabled on a machine.
The email includes:
- Machine name
- Drive encrypted
- Recovery key storage path
This is useful for compliance reporting or SOC alerting.

 4. Senior‑Level Engineering Practices
The script is written with production‑grade patterns:
- Modular functions (no duplicated logic)
- Parameterized configuration
- Input validation
- Error handling with try/catch
- Clear, structured logging
- Idempotent behavior (won’t re‑encrypt already encrypted drives)
- Safe directory creation
- Separation of local and remote execution logic

Requirements
PowerShell
- Windows PowerShell 5.1 or PowerShell 7.x
- BitLocker module installed (included in Windows 10/11 and Server 2016+)
Permissions
- Local admin rights on each machine
- Remote machines must allow PowerShell Remoting
- Network share must allow write access for recovery keys
Email (optional)
If using notifications, ensure:
- SMTP server is reachable
- Sender and recipient addresses are valid

Parameters
DriveLetter - Drive to encrypt (default: C:)
LocalKeyPath - Local folder to store recovery keys
MachinesFile - Path to text file containing remote machine names
NetworkShare - UNC path where remote recovery keys are stored
SmtpServer - SMTP server for email notifications
From - Sender email address
To - Recipient email address
EnableEmail - Switch to enable email notifications

How It Works

1. Local Machine Processing
- Checks BitLocker status
- Enables encryption if needed
- Saves recovery key locally
- Sends email (optional)

2. Remote Machine Processing
- Reads machine list from file
- Runs BitLocker enablement remotely
- Saves recovery keys to network share
- Sends email (optional)

3. Logging
All actions are written to the console for easy review or redirection to a log file.

Example Usage
.\Enable-BitLocker.ps1 `
    -DriveLetter "C:" `
    -LocalKeyPath "C:\BitLockerRecoveryKeys" `
    -MachinesFile "C:\MSP\machines.txt" `
    -NetworkShare "\\server\BitLockerRecoveryKeys" `
    -SmtpServer "smtp.example.com" `
    -From "alerts@example.com" `
    -To "admin@example.com" `
    -EnableEmail

Notes & Best Practices
- Always test on a non‑production machine first
- Ensure TPM is enabled and ready on all devices
- Store recovery keys in a secure, access‑controlled location
- Consider integrating with Azure AD or MBAM for enterprise‑grade key escrow
- Avoid storing recovery keys in plaintext unless the share is protected

License
You may include your preferred license here (MIT, Apache 2.0, etc.)
