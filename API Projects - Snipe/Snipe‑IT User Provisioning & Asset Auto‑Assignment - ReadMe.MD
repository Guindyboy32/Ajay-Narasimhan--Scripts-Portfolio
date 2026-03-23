# HR-to-Snipe-IT User Provisioning & Asset Auto-Assignment

This workflow automates the creation of users in Snipe-IT from an HR/IT source of truth (CSV, HRIS export, Okta, etc.) and optionally assigns assets to the newly created user. It resolves all required Snipe-IT IDs, performs duplicate checks, creates or updates users, and assigns hardware based on serial numbers.

This automation is designed for IT operations teams that want consistent, repeatable, and API-driven onboarding workflows.

---

## Overview

The provisioning flow:

1. **Ingest HR data** (CSV or JSON)
2. **Resolve Snipe-IT IDs**  
   - location_id  
   - company_id  
   - department_id  
3. **Check for duplicate users** (email-based)
4. **Create user** via API
5. **Optionally assign assets**  
   - Lookup asset by serial  
   - Assign to the new user
6. **Write success/error logs**

This workflow supports both **new hire provisioning** and **bulk onboarding**.

---

API Endpoints Used

### **Lookup Helpers**
Used to resolve human-readable names into Snipe-IT internal IDs.

| Purpose | Endpoint |
|--------|----------|
| Get location ID | `GET /api/v1/locations?search={{name}}` |
| Get company ID | `GET /api/v1/companies?search={{name}}` |
| Get department ID | `GET /api/v1/departments?search={{name}}` |

---

### **User Operations**

| Action | Endpoint |
|--------|----------|
| Check for existing user | `GET /api/v1/users?search={{email}}` |
| Create user | `POST /api/v1/users` |
| Update user | `PUT /api/v1/users/{id}` |

---

### **Asset Assignment**

| Action | Endpoint |
|--------|----------|
| Assign asset to user | `POST /api/v1/hardware/{asset_id}/assign` |

Assignment body:

```json
{
  "checkout_to_type": "user",
  "assigned_to": {{user_id}}
}

User Creation Payload
Example JSON body for creating a user:
{
  "first_name": "{{first_name}}",
  "last_name": "{{last_name}}",
  "username": "{{username}}",
  "email": "{{email}}",
  "employee_num": "{{employee_num}}",
  "activated": true,
  "location_id": {{location_id}},
  "company_id": {{company_id}},
  "department_id": {{department_id}},
  "notes": "Created via API by Automation"
}



End-to-End Flow
1. Input Source
- CSV export from HRIS
- JSON payload
- Okta user list
- Any structured HR data
2. Resolve IDs
For each user:
- Lookup location
- Lookup company
- Lookup department
3. Duplicate Check
Search Snipe-IT by email:
GET /api/v1/users?search={{email}}


If a match exists → fail or update, depending on your workflow.
4. Create User
POST the user JSON to:
POST /api/v1/users


Capture the returned id.
5. Asset Auto-Assignment (Optional)
For each serial number mapped to the user:
- Lookup asset:
GET /api/v1/hardware?search={{serial}}


- Extract asset_id
- Assign:
POST /api/v1/hardware/{asset_id}/assign

Hardening & Reliability✔ Duplicate Email ProtectionStops provisioning if the user already exists.✔ Retry LogicHandles:- 429 Too Many Requests
- 5xx Server Errors
Recommended: exponential backoff.✔ LoggingWrites:- Success logs
- Error logs
- API failures
- Missing IDs
- Assignment failures

Format: CSV or JSON.Example Runner WorkflowHR CSV → Parse → Resolve IDs → Duplicate Check → Create User → Assign Assets → Log Results

This can be executed via:
- PowerShell
- Python
- Postman Runner
- CI/CD pipeline
- Scheduled automation job

Why This ExistsProvisioning users manually in Snipe-IT is slow, error‑prone, and inconsistent. This automation:

- Standardizes onboarding
- Ensures correct metadata (location, department, company)
- Automatically assigns hardware
- Reduces manual IT workload
- Improves data accuracy for audits and lifecycle management



