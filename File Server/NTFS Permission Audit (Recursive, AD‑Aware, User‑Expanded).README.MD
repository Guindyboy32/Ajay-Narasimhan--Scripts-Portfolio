# NTFS Permission Audit – Recursive, AD‑Aware, User‑Expanded

This repository contains a PowerShell script designed to perform a **full NTFS permission audit** across an entire folder hierarchy. It expands AD groups into individual users, filters permissions, and exports a clean, user‑friendly CSV report.

This tool is ideal for security reviews, access audits, compliance checks, and file server migrations.

--- Overview

The script performs a deep, recursive scan of a target directory and collects:

- NTFS ACLs for every folder  
- Expanded AD group membership (including nested groups)  
- User‑level permission mapping  
- Rights filtering (Read, Write, Modify, FullControl, etc.)  
- Inheritance details  
- Access type (Allow/Deny)

It outputs a **flat CSV** where each row represents a single user’s effective permissions on a specific folder.

--- Features

- **Interactive prompts** for scan path and export path  
- **Full recursive scan** of all subfolders  
- **Expands AD groups** into actual users (nested included)  
- **Skips large/global groups** (Domain Users, Authenticated Users, Everyone, etc.)  
- **Handles BUILTIN and local accounts** without errors  
- **Filters permissions** to meaningful rights only  
- **Exports clean CSV** for reporting or analysis  
- **Automatically creates export directory** if missing  

---  Example Input

When prompted, you might enter: \TestDomain-FS01\DeptShares\IT_Operations

2. Enter the folder path to scan
Example:
\\TestDomain-FS01\DeptShares\IT_Operations


3. Enter the export directory
Example:
C:\Temp


4. Script runs and generates:
NTFS_Permission_Audit.csv


Saved to your chosen export directory.


