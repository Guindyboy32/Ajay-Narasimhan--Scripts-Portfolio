How the Automation Works


This automation framework converts a traditionally manual Azure AI deployment into a fully orchestrated, repeatable, and deterministic pipeline.
The script follows a strict, dependency‑aware sequence to ensure that each Azure component is provisioned, configured, and validated in the correct order.

1. Resource Initialization
The script begins by:
- Selecting the correct Azure subscription
- Creating (or validating) the Resource Group
- Establishing the deployment boundary
This ensures all resources share lifecycle, region, and cost alignment.

2. Content Ingestion Layer
For Wiki LLM:
- Markdown, HTML, or Wiki pages are extracted
- Files are uploaded to Azure Blob Storage
- Storage keys and container paths are validated
This forms the ground truth dataset for the LLM.
For HelpDesk:
- Configuration files
- JSON/YAML profiles
- API tokens (secure)
- Module imports
This forms the operational automation layer.

3. Azure AI Search Provisioning
The script deploys Azure AI Search and configures:
- Data Source
- Index schema
- Indexer
- Semantic Ranker
This creates the retrieval engine that powers the LLM’s grounding.

4. Indexer Execution
The indexer is triggered immediately to:
- Chunk documents
- Generate embeddings
- Populate the index
- Validate ingestion
This ensures the LLM can answer questions using the latest content.

5. Azure OpenAI Integration
The script configures:
- GPT model deployment
- Embedding model deployment
- System prompts
- Temperature, strictness, and top‑k
This defines the reasoning layer of the LLM.

6. Web Application Configuration
The script injects all required environment variables:
- OpenAI endpoint + key
- Search service + index
- Embedding model
- Temperature + strictness
- Authentication flags
This ensures the web app behaves consistently across environments.

7. Web App Restart & Validation
Finally, the script:
- Restarts the web app
- Validates connectivity
- Confirms index availability
- Performs test queries
This ensures the environment is fully operational end‑to‑end.

Outcome
The automation delivers:
- Zero‑touch deployment
- Consistent, repeatable environments
- Enterprise‑grade LLM architecture
- Rapid re‑deployment for demos, POCs, and multi‑tenant scenarios
This is the level of automation expected from a senior cloud engineer or architect.
