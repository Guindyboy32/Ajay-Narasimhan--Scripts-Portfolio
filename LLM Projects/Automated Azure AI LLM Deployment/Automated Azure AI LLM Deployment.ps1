<#
.SYNOPSIS
Automates deployment of an Azure AI LLM environment:
- Resource Group
- Storage Account + Container
- Document Upload
- Azure AI Search (Data Source, Index, Indexer)
- Web App Configuration

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
    [Parameter(Mandatory=$true)] [string]$SearchKey,
    [Parameter(Mandatory=$true)] [string]$ModelName,
    [Parameter(Mandatory=$true)] [string]$EmbeddingName,
    [Parameter(Mandatory=$true)] [string]$LocalDocsPath
)

Write-Host "Starting Azure AI LLM Deployment..." -ForegroundColor Cyan

# ------------------------------------------------------------
# 1. Login & Subscription
# ------------------------------------------------------------
Write-Host "Setting subscription..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId

# ------------------------------------------------------------
# 2. Resource Group
# ------------------------------------------------------------
Write-Host "Creating Resource Group..." -ForegroundColor Yellow
az group create `
    --name $ResourceGroupName `
    --location $Location `
    --output none

# ------------------------------------------------------------
# 3. Storage Account + Container
# ------------------------------------------------------------
Write-Host "Creating Storage Account..." -ForegroundColor Yellow
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

Write-Host "Creating Blob Container..." -ForegroundColor Yellow
az storage container create `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --account-key $StorageKey `
    --output none

Write-Host "Uploading documents..." -ForegroundColor Yellow
az storage blob upload-batch `
    --destination $ContainerName `
    --source $LocalDocsPath `
    --account-name $StorageAccountName `
    --account-key $StorageKey `
    --output none

# ------------------------------------------------------------
# 4. Azure AI Search
# ------------------------------------------------------------
Write-Host "Creating Azure AI Search service..." -ForegroundColor Yellow
az search service create `
    --name $SearchServiceName `
    --resource-group $ResourceGroupName `
    --sku standard `
    --location $Location `
    --output none

# ------------------------------------------------------------
# 5. Create Data Source
# ------------------------------------------------------------
Write-Host "Creating Search Data Source..." -ForegroundColor Yellow

$DataSourceJson = @"
{
  "name": "datasource-blob",
  "type": "azureblob",
  "credentials": { "connectionString": "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$StorageKey" },
  "container": { "name": "$ContainerName" }
}
"@

az rest --method put `
    --uri "https://$SearchServiceName.search.windows.net/datasources/datasource-blob?api-version=2023-11-01" `
    --headers "Content-Type=application/json" "api-key=$SearchKey" `
    --body $DataSourceJson

# ------------------------------------------------------------
# 6. Create Index
# ------------------------------------------------------------
Write-Host "Creating Search Index..." -ForegroundColor Yellow

$IndexJson = @"
{
  "name": "docs-index",
  "fields": [
    { "name": "chunk_id", "type": "Edm.String", "key": true, "searchable": true, "filterable": true, "sortable": true },
    { "name": "content", "type": "Edm.String", "searchable": true },
    { "name": "filepath", "type": "Edm.String", "searchable": true }
  ]
}
"@

az rest --method put `
    --uri "https://$SearchServiceName.search.windows.net/indexes/docs-index?api-version=2023-11-01" `
    --headers "Content-Type=application/json" "api-key=$SearchKey" `
    --body $IndexJson

# ------------------------------------------------------------
# 7. Create Indexer
# ------------------------------------------------------------
Write-Host "Creating Search Indexer..." -ForegroundColor Yellow

$IndexerJson = @"
{
  "name": "docs-indexer",
  "dataSourceName": "datasource-blob",
  "targetIndexName": "docs-index",
  "schedule": { "interval": "PT1H" }
}
"@

az rest --method put `
    --uri "https://$SearchServiceName.search.windows.net/indexers/docs-indexer?api-version=2023-11-01" `
    --headers "Content-Type=application/json" "api-key=$SearchKey" `
    --body $IndexerJson

Write-Host "Running Indexer..." -ForegroundColor Yellow
az rest --method post `
    --uri "https://$SearchServiceName.search.windows.net/indexers/docs-indexer/run?api-version=2023-11-01" `
    --headers "api-key=$SearchKey"

# ------------------------------------------------------------
# 8. Configure Web App
# ------------------------------------------------------------
Write-Host "Configuring Web App environment variables..." -ForegroundColor Yellow

$Settings = @{
    "AZURE_OPENAI_ENDPOINT" = $OpenAIEndpoint
    "AZURE_OPENAI_KEY"      = $OpenAIKey
    "AZURE_OPENAI_MODEL"    = $ModelName
    "AZURE_OPENAI_EMBEDDING_NAME" = $EmbeddingName
    "AZURE_SEARCH_SERVICE"  = $SearchServiceName
    "AZURE_SEARCH_INDEX"    = "docs-index"
    "AZURE_SEARCH_KEY"      = $SearchKey
    "AZURE_SEARCH_ENABLE_IN_DOMAIN" = "True"
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

Write-Host "Deployment Complete!" -ForegroundColor Green
