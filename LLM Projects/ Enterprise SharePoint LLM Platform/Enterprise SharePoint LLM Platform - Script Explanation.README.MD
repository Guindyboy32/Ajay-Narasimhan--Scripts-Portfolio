This script automates the full deployment lifecycle of a SharePoint‑integrated LLM platform.

Here’s the high‑level flow:

1. Subscription & Resource Group Initialization
The script ensures the correct subscription is active and creates the Resource Group if it doesn’t already exist.
This establishes the deployment boundary for all Azure resources.

2. Azure AI Search Provisioning
The script deploys the Azure AI Search service, which acts as the semantic retrieval engine for SharePoint content.
This includes:
- Search service creation
- Semantic ranker enablement
- Admin key retrieval

3. SharePoint Data Source Creation
The script registers a SharePoint Graph Connector data source using:
- Tenant ID
- Connection ID
- OAuth‑based authentication
This allows Azure AI Search to crawl SharePoint Online securely.

4. Index Schema Deployment
The script creates a custom index optimized for SharePoint content:
- Title
- Content
- Path
- Last modified date
- Permissions
This ensures the LLM respects SharePoint access control.

5. Indexer Creation & Execution
The script configures an indexer that:
- Crawls SharePoint
- Extracts content
- Generates embeddings
- Populates the index
It then triggers an immediate run so the LLM can start answering questions right away.

6. Web App Configuration
The script injects all required environment variables into the Web App:
- OpenAI model + embedding model
- Search service + index
- SharePoint connection ID
- Tenant ID
- Temperature, strictness, and other tuning parameters
This ensures the LLM behaves consistently across environments.

7. Web App Restart & Validation
Finally, the script restarts the Web App to apply all changes and ensures the environment is fully operational.

Deployment Flow Summary
- Run the PowerShell script with your parameters
- Script provisions Azure AI Search
- Script registers SharePoint as a data source
- Script builds the index + indexer
- Script configures the Web App
- Script restarts the Web App
- SharePoint LLM is ready for use
