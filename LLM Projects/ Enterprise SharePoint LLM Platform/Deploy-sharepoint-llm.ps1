<#
.SYNOPSIS
Automates deployment of a SharePoint-integrated LLM environment using:
- Azure OpenAI
- Azure AI Search
- SharePoint Graph Connector
- Azure Web App

Author: Ajay Narasimhan
#>

param(
    [Parameter(Mandatory=$true)] [string]$SubscriptionId,
    [Parameter(Mandatory=$true)] [string]$ResourceGroupName,
    [Parameter(Mandatory=$true)] [string]$Location,
    [Parameter(Mandatory=$true)] [string]$SearchServiceName,
    [Parameter(Mandatory=$true)] [string]$WebAppName,
    [Parameter(Mandatory=$true)] [string]$OpenAIEndpoint,
    [Parameter(Mandatory=$true)] [string]$OpenAIKey,
    [Parameter(Mandatory=$true)] [string]$ModelName,
    [Parameter(Mandatory=$true)] [string]$EmbeddingName,
    [Parameter(Mandatory=$true)] [string]$SharePointConnectionId,
    [Parameter(Mandatory=$true)] [string]$TenantId,
    [Parameter(Mandatory=$true)] [string]$SearchAdminKey
)

Write-Host "Starting SharePoint LLM Deployment..." -ForegroundColor Cyan

# ------------------------------------------------------------
# 1. Subscription
# ------------------------------------------------------------
Write-Host "Setting subscription..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId

# ------------------------------------------------------------
# 2. Resource Group
# ------------------------------------------------------------
Write-Host "Ensuring Resource Group exists..." -ForegroundColor Yellow
az group create `
    --name $ResourceGroupName `
    --location $Location `
    --output none

# ------------------------------------------------------------
# 3. Azure AI Search
# ------------------------------------------------------------
Write-Host "Creating Azure AI Search service..." -ForegroundColor Yellow
az search service create `
    --name $SearchServiceName `
    --resource-group $ResourceGroupName `
    --sku standard `
    --location $Location `
    --output none

# ------------------------------------------------------------
# 4. SharePoint Data Source
# ------------------------------------------------------------
Write-Host "Creating SharePoint Data Source..." -ForegroundColor Yellow

$DataSourceJson = @"
{
  "name": "sharepoint-datasource",
  "type": "sharepoint",
  "credentials": {
    "connectionId": "$SharePointConnectionId",
    "tenantId": "$TenantId"
  },
  "container": {
    "name": "sharepoint"
  }
}
"@

az rest --method put `
    --uri "https://$SearchServiceName.search.windows.net/datasources/sharepoint-datasource?api-version=2023-11-01" `
    --headers "Content-Type=application/json" "api-key=$SearchAdminKey" `
    --body $DataSourceJson

# ------------------------------------------------------------
# 5. Index Schema
# ------------------------------------------------------------
Write-Host "Creating SharePoint Index..." -ForegroundColor Yellow

$IndexJson = @"
{
  "name": "sharepoint-index",
  "fields": [
    { "name": "id", "type": "Edm.String", "key": true, "searchable": false },
    { "name": "title", "type": "Edm.String", "searchable": true },
    { "name": "content", "type": "Edm.String", "searchable": true },
    { "name": "path", "type": "Edm.String", "searchable": true },
    { "name": "lastModified", "type": "Edm.DateTimeOffset", "filterable": true },
    { "name": "permissions", "type": "Collection(Edm.String)", "filterable": true }
  ]
}
"@

az rest --method put `
    --uri "https://$SearchServiceName.search.windows.net/indexes/sharepoint-index?api-version=2023-11-01" `
    --headers "Content-Type=application/json" "api-key=$SearchAdminKey" `
    --body $IndexJson

# ------------------------------------------------------------
# 6. Indexer
# ------------------------------------------------------------
Write-Host "Creating SharePoint Indexer..." -ForegroundColor Yellow

$IndexerJson = @"
{
  "name": "sharepoint-indexer",
  "dataSourceName": "sharepoint-datasource",
  "targetIndexName": "sharepoint-index",
  "schedule": { "interval": "PT2H" }
}
"@

az rest --method put `
    --uri "https://$SearchServiceName.search.windows.net/indexers/sharepoint-indexer?api-version=2023-11-01" `
    --headers "Content-Type=application/json" "api-key=$SearchAdminKey" `
    --body $IndexerJson

Write-Host "Running Indexer..." -ForegroundColor Yellow
az rest --method post `
    --uri "https://$SearchServiceName.search.windows.net/indexers/sharepoint-indexer/run?api-version=2023-11-01" `
    --headers "api-key=$SearchAdminKey"

# ------------------------------------------------------------
# 7. Web App Configuration
# ------------------------------------------------------------
Write-Host "Configuring Web App..." -ForegroundColor Yellow

$Settings = @{
    "AZURE_OPENAI_ENDPOINT" = $OpenAIEndpoint
    "AZURE_OPENAI_KEY"      = $OpenAIKey
    "AZURE_OPENAI_MODEL"    = $ModelName
    "AZURE_OPENAI_EMBEDDING_NAME" = $EmbeddingName
    "AZURE_SEARCH_SERVICE"  = $SearchServiceName
    "AZURE_SEARCH_INDEX"    = "sharepoint-index"
    "AZURE_SEARCH_KEY"      = $SearchAdminKey
    "SHAREPOINT_CONNECTION_ID" = $SharePointConnectionId
    "TENANT_ID" = $TenantId
    "AZURE_OPENAI_TEMPERATURE" = "0"
}

foreach ($key in $Settings.Keys) {
    az webapp config appsettings set `
        --name $WebAppName `
        --resource-group $ResourceGroupName `
        --settings "$key=$($Settings[$key])" `
        --output none
}

Write-Host "Restarting Web App..." -ForegroundColor Yellow
az webapp restart `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --output none

Write-Host "SharePoint LLM Deployment Complete!" -ForegroundColor Green
