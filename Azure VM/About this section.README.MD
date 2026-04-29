Overview

This repository contains a curated collection of PowerShell and Azure CLI scripts designed to automate common Azure Virtual Machine (VM) lifecycle and management tasks. These scripts help administrators streamline operations, enforce consistency, and reduce manual effort across development, test, and production environments.
The collection covers VM provisioning, configuration, scaling, lifecycle operations, and resource management. Each script is self‑contained and can be executed independently.

Prerequisites

Before using these scripts, ensure you have a working understanding of:
• 	Azure Virtual Machines and VM architecture
• 	Azure Resource Manager (ARM) concepts
• 	VM sizing, networking, and storage fundamentals
• 	Azure PowerShell (Az module) and/or Azure CLI

Required Tools
• 	Azure PowerShell (Az module)
• 	Azure CLI (for CLI‑based scripts)
• 	PowerShell 7.x or Windows PowerShell 5.1
• 	Azure RBAC permissions: Contributor or higher

Authentication
You must authenticate before running any script:

Azure PowerShell - Connect-AzAccount

Azure CLI - az login


Script Categories

1. VM Creation & Configuration


2. Disk Management


3. VM Lifecycle Operations


4. Scaling & Automation


5. Resource Management


Best Practices
• 	Test scripts in a non‑production environment before deployment.
• 	Review and update variable values before execution.
• 	Understand the impact of resizing, redeploying, or moving VMs.
• 	Be aware that some scripts may incur Azure costs (VM creation, scaling, disk attachment).
• 	Use version control and change tracking for operational scripts.
