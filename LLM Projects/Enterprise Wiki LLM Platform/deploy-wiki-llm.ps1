<#
.SYNOPSIS
Automates deployment of a Wiki‑powered LLM using:
- Azure OpenAI
- Azure AI Search
- Azure Storage (Wiki content ingestion)
- Azure Web App

Author: Ajay Narasimhan
#>

param(
    [Parameter(Mandatory=$true)] [string]$SubscriptionId,
    [Parameter(Mandatory=$true)] [string]$ResourceGroupName,
    [Parameter(Mandatory=$true)] [string]$Location,
    [Parameter(Mandatory=$true)] [string]$StorageAccountName,
    [Parameter(Mandatory=$true)] [string]$ContainerName,
    [Parameter(Mandatory=$true)] [string]$SearchServiceName,
    [Parameter(Mandatory=$true)] [string]$WebAppName,
    [Parameter(Mandatory=$true)] [string]$OpenAIEndpoint,
    [Parameter(Mandatory=$true)] [string]$OpenAIKey,
    [Parameter(Mandatory=$true)] [string]$ModelName,
    [Parameter(Mandatory=$true)] [string]$EmbeddingName,
    [Parameter(Mandatory=$true)] [string]$LocalWikiPath,
    [Parameter(Mandatory=$true)] [string]$SearchAdminKey
)

Write-Host "Starting Wiki LLM Deployment..." -ForegroundColor Cyan

# ------------------------------------------------------------
# 1. Subscription
# ------------------------------------------------------------
az account set --subscription $SubscriptionId

# ------------------------------------------------------------
# 2. Resource Group
# ------------------------------------------------------------
az group create `
    --name $ResourceGroupName `
    --location $Location `
    --output none

# ------------------------------------------------------------
# 3. Storage Account + Container
# ------------------------------------------------------------
az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --output none

$StorageKey = az storage account keys list `
    --resource-group $ResourceGroupName `
    --account-name $StorageAccountName `
    --query "[0].value" -o tsv

az storage container create `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --account-key $StorageKey `
    --output none

az storage blob upload-batch `
    --destination $ContainerName `
    --source $LocalWikiPath `
    --account-name $StorageAccountName `
    --account-key $StorageKey `
    --output none

# ------------------------------------------------------------
# 4. Azure AI Search
# ------------------------------------------------------------
az search service create `
    --name $SearchServiceName `
    --resource-group $ResourceGroupName `
    --sku standard `
    --location $Location `
    --output none

# ------------------------------------------------------------
# 5. Data Source
# ------------------------------------------------------------
$DataSourceJson = @"
{
  "name": "wiki-datasource",
  "type": "azureblob",
  "credentials": {
    "connectionString": "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$StorageKey"
  },
  "container": {
    "name": "$ContainerName"
  }
}
"@

az rest --method put `
    --uri "https://$SearchServiceName.search.windows.net/datasources/wiki-datasource?api-version=2023-11-01" `
    --headers "Content-Type=application/json" "api-key=$SearchAdminKey" `
    --body $DataSourceJson

# ------------------------------------------------------------
# 6. Index Schema
# ------------------------------------------------------------
$IndexJson = @"
{
  "name": "wiki-index",
  "fields": [
    { "name": "id", "type": "Edm.String", "key": true },
    { "name": "title", "type": "Edm.String", "searchable": true },
    { "name": "content", "type": "Edm.String", "searchable": true },
    { "name": "filepath", "type": "Edm.String", "searchable": true },
    { "name": "lastModified", "type": "Edm.DateTimeOffset", "filterable": true }
  ]
}
"@

az rest --method put `
    --uri "https://$SearchServiceName.search.windows.net/indexes/wiki-index?api-version=2023-11-01" `
    --headers "Content-Type=application/json" "api-key=$SearchAdminKey" `
    --body $IndexJson

# ------------------------------------------------------------
# 7. Indexer
# ------------------------------------------------------------
$IndexerJson = @"
{
  "name": "wiki-indexer",
  "dataSourceName": "wiki-datasource",
  "targetIndexName": "wiki-index",
  "schedule": { "interval": "PT1H" }
}
"@

az rest --method put `
    --uri "https://$SearchServiceName.search.windows.net/indexers/wiki-indexer?api-version=2023-11-01" `
    --headers "Content-Type=application/json" "api-key=$SearchAdminKey" `
    --body $IndexerJson

az rest --method post `
    --uri "https://$SearchServiceName.search.windows.net/indexers/wiki-indexer/run?api-version=2023-11-01" `
    --headers "api-key=$SearchAdminKey"

# ------------------------------------------------------------
# 8. Web App Configuration
# ------------------------------------------------------------
$Settings = @{
    "AZURE_OPENAI_ENDPOINT" = $OpenAIEndpoint
    "AZURE_OPENAI_KEY"      = $OpenAIKey
    "AZURE_OPENAI_MODEL"    = $ModelName
    "AZURE_OPENAI_EMBEDDING_NAME" = $EmbeddingName
    "AZURE_SEARCH_SERVICE"  = $SearchServiceName
    "AZURE_SEARCH_INDEX"    = "wiki-index"
    "AZURE_SEARCH_KEY"      = $SearchAdminKey
    "AZURE_OPENAI_TEMPERATURE" = "0"
}

foreach ($key in $Settings.Keys) {
    az webapp config appsettings set `
        --name $WebAppName `
        --resource-group $ResourceGroupName `
        --settings "$key=$($Settings[$key])" `
        --output none
}

az webapp restart `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --output none

Write-Host "Wiki LLM Deployment Complete!" -ForegroundColor Green
