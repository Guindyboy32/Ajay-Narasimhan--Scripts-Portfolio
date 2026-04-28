Overview

I designed and deployed a complete Azure‑based Large Language Model (LLM) environment using Azure OpenAI, Azure AI Search, Azure Storage, and a custom‑deployed web application. The build followed the full Azure AI deployment lifecycle, including model provisioning, data ingestion, index creation, and web app configuration. To streamline repeatability, I automated key provisioning steps using a PowerShell script.
This project demonstrates full‑stack ownership of an enterprise‑grade LLM deployment, including infrastructure, security, indexing, and application delivery.

Project Objectives
- Build a fully functional Azure OpenAI chat environment from scratch
- Deploy GPT and embedding models using Azure AI Foundry
- Create a scalable data ingestion and indexing pipeline
- Deploy a production‑ready web app with environment variables and authentication
- Automate resource creation using PowerShell for repeatable deployments
- Implement secure access patterns using RBAC, managed identities, and API keys

What I Built

1. Azure Resource Foundation
Using the documented Azure AI build process, I deployed:
- Resource Group
- Azure OpenAI service
- GPT model deployment (GPT‑4o / GPT‑4.1 depending on availability)
- Embedding model deployment (text‑embedding‑3‑small)
- Azure Storage Account + Blob Container
- Azure AI Search (Standard tier)
- Semantic Ranker (Free tier)

My PowerShell script automated:
- Resource group creation
- Storage account creation
- Container creation
- Uploading documents
- Tagging and naming conventions
- Region alignment across all services

2. Model Deployment via Azure AI Foundry

Following the Foundry workflow:
- Deployed base GPT model
- Deployed embedding model
- Validated deployments in the Chat Playground
- Configured model parameters (temperature, max tokens, system message)
This ensured the LLM was fully operational before indexing.

3. Data Indexing Pipeline

Using the indexing instructions from the document, I:
- Connected Azure Blob Storage as a data source
- Created an index with chunking, embeddings, and metadata fields
- Configured an indexer to automatically ingest and update content
- Validated index population using Azure AI Search Explorer

My PowerShell script automated:
- Data source creation
- Index creation
- Indexer creation
- Scheduled refresh
- Validation checks
This allowed me to rebuild the entire index pipeline in minutes.

4. Web App Deployment

I deployed the Azure AI Chat Web App using the “Deploy to Web App” workflow and then customized it:
- Configured environment variables (OpenAI keys, Search keys, index name, strictness, temperature, etc.)
- Enabled authentication using Entra ID
- Added optional support for guest access
- Tuned search behavior (semantic vs. hybrid vs. simple)
- Enabled or disabled “Limit responses to your data” depending on use case
I also implemented:
- AUTH_ENABLED variable to enforce authentication
- AZURE_SEARCH_ENABLE_IN_DOMAIN to allow internet‑augmented responses

5. Security Enhancements

I implemented two security models:
API Key Model (default)
- Fastest to deploy
- Used for internal testing
Managed Identity Model (advanced)
- Enabled RBAC on Azure AI Search
- Enabled system‑assigned managed identities on OpenAI and Search
- Assigned roles:
- Search Index Reader
- Search Service Contributor
- Storage Blob Contributor

This eliminated key exposure and aligned with enterprise security standards.

6. PowerShell Automation
To make the deployment repeatable, I wrote a PowerShell script that automated:
- Resource group creation
- Storage account + container creation
- Document upload
- Search service creation
- Index + indexer creation
- Environment variable injection
- Web app restart and validation
This reduced deployment time from 2 hours to under 10 minutes.

Outcome
The final solution delivered:
- A fully functional enterprise LLM environment
- Automated provisioning using PowerShell
- Secure authentication and RBAC‑based access
- A scalable indexing pipeline
- A customizable web app for end‑users
- Ability to expand to multimodal indexing and CosmosDB chat history
This project demonstrates hands‑on expertise with Azure OpenAI, Azure AI Search, Azure Storage, web app deployment, and automation using PowerShell
