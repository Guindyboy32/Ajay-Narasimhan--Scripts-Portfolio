This folder contains a collection of PowerShell and Azure CLI scripts designed to automate common Azure Virtual Machine (VM) management tasks. These scripts are intended for administrators who want to streamline VM operations, reduce manual effort, and maintain consistent configurations across environments.
Before using these scripts, it is strongly recommended that you have a basic understanding of:
- Azure Virtual Machines
- Azure Resource Manager (ARM)
- VM sizing, storage, and networking
- Azure CLI and/or Azure PowerShell modules
If you are new to Azure, consider completing introductory Azure courses before applying these scripts in a production environment.

Purpose
These scripts help automate tasks such as:
- Creating, resizing, and redeploying VMs
- Managing VM disks
- Starting, stopping, and deallocating VMs
- Scaling VM workloads
- Moving VMs between resource groups
- Automating VM shutdown or scaling based on metrics
Each script is self‑contained and can be run independently.

Script Index
Below is a high‑level overview of the scripts included in this folder:

VM Creation & Configuration
- Create a Virtual Machine in Azure.ps1

Creates a new Azure VM using PowerShell.
- Creating Azure instance‑VDI.ps1

Script for provisioning a VDI‑style Azure VM.
- Change VM Size and Configuration Using PowerShell.ps1

Updates VM size, SKU, or configuration settings.
- Resize VM.ps1

Quickly resize an existing VM.
Disk Management
- Attach a Data Disk to a VM using PowerShell.ps1

Adds a new managed disk to an existing VM.
VM Lifecycle Operations
- Start and Stop Multiple VMs using PowerShell.ps1

Bulk start/stop operations for multiple VMs.
- Start and stop Azure VM.ps1

Start or stop a single VM.
- Deallocate a Virtual Machine using Azure CLI.ps1

Deallocates a VM to save compute costs.
- Restarting VM.ps1

Restarts a VM using PowerShell.
- Redeploy a Virtual Machine using PowerShell.ps1

Redeploys a VM to a new Azure host.
Scaling & Automation
- Configure VM Scale Set using PowerShell.ps1

Creates or configures a VM Scale Set.
- Script to Automate VM Scaling Based on CPU Usage.ps1

Automatically scales VM resources based on CPU thresholds.
- automate VM shutdown.ps1

Automates scheduled VM shutdown.
Resource Management
- Move a VM to a Different Resource Group using PowerShell.ps1
Moves a VM and its associated resources to another resource group.

Requirements

To run these scripts, ensure you have:
- Azure PowerShell module (Az module)
- Azure CLI (for CLI‑based scripts)
- Appropriate Azure RBAC permissions (Contributor or higher)
- PowerShell 7.x or Windows PowerShell 5.1
Login is required before running any script:
Azure PowerShell
Connect-AzAccount


Azure CLI
az login


Notes
- Always test scripts in a non‑production environment first.
- Some scripts may incur Azure costs (VM creation, scaling, disk attachment).
- Review and modify variables inside each script before running.
- Ensure you understand the impact of resizing, redeploying, or moving VMs.

