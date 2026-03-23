A production‑ready workflow for bulk‑creating hardware assets in Snipe‑IT using either Postman or a Python automation script.
This blueprint handles ID resolution, validation, retries, logging, and custom fields—making it safe for real‑world deployments.

Overview

This project provides two ways to provision hardware assets into Snipe‑IT:

1. Postman Runner Workflow
A two‑step request flow that resolves IDs dynamically and creates assets using a JSON data file.
2. Python Automation Script
A robust, retry‑safe script that reads a master JSON file, resolves IDs, creates assets, and logs results to CSV.
Both approaches use the same input format and support custom fields.

1. Input Format
Create a file named assets_to_create.json:
[
  {
    "serial": "ADADAdda",
    "asset_tag": "TEST-ADADAdda",
    "status": "Ready to Deploy",
    "model": "DELLVO",
    "location": "Hogwarts",
    "category": "Dellvoss",
    "custom": {
      "_snipeit_lte_capable_8": "Yes",
      "_snipeit_warranty_expiry_7": "2028-04-18",
      "_snipeit_warranty_type_6": "DEVLO"
    }
  },
  {
    "serial": "DADADADA",
    "asset_tag": "TST-DADADADA",
    "status": "Ready to Deploy",
    "model": "DELLVO",
    "location": "Hogwarts",
    "category": "Dellvosss",
    "custom": {
      "_snipeit_lte_capable_8": "Yes",
      "_snipeit_warranty_expiry_7": "2028-04-18",
      "_snipeit_warranty_type_6": "DEVLO"
    }
  }
]


This file drives both the Postman runner and the Python script.

2. Postman Workflow
The Postman approach uses three requests per asset:
- Resolve Model ID
- Resolve Location ID
- Resolve Status ID
- Create Asset
✔ Request A — Resolve Model ID
GET https://TESSTDOMAIN.snipe-it.io/api/v1/models?search={{model}}&limit=1

Tests tab:
const m = pm.response.json();
const modelId = m?.rows?.[0]?.id;
pm.test("Model found", () => pm.expect(modelId, "No model match").to.be.a("number"));
pm.variables.set("model_id", modelId);

Repeat the same pattern for locations and statuslabels.

Request B — Create Asset
POST https://TESSTDOMAIN.snipe-it.io/api/v1/hardware

Body:
{
  "location_id": {{location_id}},
  "name": "{{serial}}",
  "status_id": {{status_id}},
  "asset_tag": "{{asset_tag}}",
  "model_id": {{model_id}},
  "serial": "{{serial}}",
  "category_id": 17,
  "_snipeit_lte_capable_8": "{{custom._snipeit_lte_capable_8}}",
  "_snipeit_warranty_expiry_7": "{{custom._snipeit_warranty_expiry_7}}",
  "_snipeit_warranty_type_6": "{{custom._snipeit_warranty_type_6}}"
}

▶ Running the Collection
- Open Runner
- Load assets_to_create.json as the data file
- Order the requests:
- Resolve Model
- Resolve Location
- Resolve Status
- Create Asset
- Run — one iteration per asset

3. Python Automation Script
A single-file, production‑ready script with:
- Dynamic ID lookup
- Exponential backoff for 429/5xx
- Success & error CSV logs
- Custom field support
- Clear error handling
Save as provision_assets.py and set:
export SNIPE_TOKEN=xxxxxxxxxxxx

Then run:
python3 provision_assets.py


The script reads assets_to_create.json and produces:
- assets_created.csv
- assets_errors.csv

What This System Provides

* Dynamic ID Resolution
No hard‑coded IDs. Models, locations, and statuses are resolved by name.
* Safe, Retry‑Aware API Calls
Handles rate limits and transient failures with exponential backoff.
* Full Logging
* CSV logs for audit, troubleshooting, and reporting.
* Custom Field Support
Any custom Snipe‑IT field can be passed through the custom object.
* Extensible Architecture
Easily add:
- Category lookups
- Assigned‑to user lookups
- Department mapping
- Auto‑naming conventions

Recommended Use Cases
- Bulk provisioning new hardware shipments
- Migrating assets from spreadsheets
- Automating onboarding workflows
- Standardizing asset creation across teams
