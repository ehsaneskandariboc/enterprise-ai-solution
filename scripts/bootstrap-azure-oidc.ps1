<#
.SYNOPSIS
  One-time bootstrap of Azure OIDC (workload identity) + GitHub secrets so the
  Terraform CI/CD workflows in this repo can authenticate to Azure with no
  long-lived credentials.

.DESCRIPTION
  Creates / reuses (idempotent):
    - An Entra app registration + service principal
    - Federated credentials for the repo's pull_request, main branch, and the
      'dev' / 'prod' deployment environments
    - Contributor + User Access Administrator role assignments on the subscription
    - A resource group + storage account + container for Terraform remote state
    - GitHub 'dev' / 'prod' environments
    - The six repo secrets consumed by the workflows

.PREREQUISITES
  - Azure CLI, logged in:   az login
  - GitHub CLI, logged in:  gh auth login   (account must admin this repo)
  - Permission to create Entra app registrations and assign subscription roles

.EXAMPLE
  ./scripts/bootstrap-azure-oidc.ps1
  ./scripts/bootstrap-azure-oidc.ps1 -Location westeurope -SubscriptionId <sub-guid>
#>
[CmdletBinding()]
param(
  [string]$Repo               = "ehsaneskandariboc/enterprise-ai-solution",
  [string]$AppName            = "gh-enterprise-ai-oidc",
  [string]$Location           = "eastus",
  [string]$StateResourceGroup = "rg-entai-tfstate",
  [string]$StateContainer     = "tfstate",
  [string]$SubscriptionId     = "",
  [string]$StorageAccountName = ""
)

$ErrorActionPreference = "Stop"

function Info($m) { Write-Host "==> $m" -ForegroundColor Cyan }

# --- 0. Context -------------------------------------------------------------
if (-not $SubscriptionId) { $SubscriptionId = (az account show --query id -o tsv) }
if (-not $SubscriptionId) { throw "Not logged in. Run 'az login' first." }
az account set --subscription $SubscriptionId | Out-Null
$TenantId = (az account show --query tenantId -o tsv)
Info "Subscription : $SubscriptionId"
Info "Tenant       : $TenantId"
Info "Repo         : $Repo"

# --- 1. App registration + service principal --------------------------------
$AppId = (az ad app list --display-name $AppName --query "[0].appId" -o tsv)
if (-not $AppId) {
  Info "Creating app registration '$AppName'"
  $AppId = (az ad app create --display-name $AppName --query appId -o tsv)
} else {
  Info "Reusing app registration '$AppName' ($AppId)"
}

$SpObjectId = (az ad sp show --id $AppId --query id -o tsv 2>$null)
if (-not $SpObjectId) {
  Info "Creating service principal"
  $SpObjectId = (az ad sp create --id $AppId --query id -o tsv)
}

# --- 2. Federated credentials ----------------------------------------------
$subjects = [ordered]@{
  "gh-pull-request" = "repo:${Repo}:pull_request"
  "gh-branch-main"  = "repo:${Repo}:ref:refs/heads/main"
  "gh-env-dev"      = "repo:${Repo}:environment:dev"
  "gh-env-prod"     = "repo:${Repo}:environment:prod"
}
$existingFic = (az ad app federated-credential list --id $AppId --query "[].name" -o tsv)
foreach ($name in $subjects.Keys) {
  if ($existingFic -contains $name) {
    Info "Federated credential '$name' already exists"
    continue
  }
  Info "Creating federated credential '$name'"
  $params = @{
    name      = $name
    issuer    = "https://token.actions.githubusercontent.com"
    subject   = $subjects[$name]
    audiences = @("api://AzureADTokenExchange")
  } | ConvertTo-Json -Compress
  $params | az ad app federated-credential create --id $AppId --parameters "@-" | Out-Null
}

# --- 3. Role assignments ----------------------------------------------------
foreach ($role in @("Contributor", "User Access Administrator")) {
  Info "Ensuring role '$role' on the subscription"
  az role assignment create `
    --assignee-object-id $SpObjectId `
    --assignee-principal-type ServicePrincipal `
    --role $role `
    --scope "/subscriptions/$SubscriptionId" 2>$null | Out-Null
}

# --- 4. Remote state storage ------------------------------------------------
Info "Ensuring resource group '$StateResourceGroup'"
az group create -n $StateResourceGroup -l $Location | Out-Null

if (-not $StorageAccountName) {
  $rand = -join ((48..57) + (97..122) | Get-Random -Count 6 | ForEach-Object { [char]$_ })
  $StorageAccountName = "stentaitf$rand"   # <= 24 chars, lower alnum
}
$saExists = (az storage account show -n $StorageAccountName -g $StateResourceGroup --query name -o tsv 2>$null)
if (-not $saExists) {
  Info "Creating storage account '$StorageAccountName'"
  az storage account create `
    -n $StorageAccountName -g $StateResourceGroup -l $Location `
    --sku Standard_LRS --min-tls-version TLS1_2 --allow-blob-public-access false | Out-Null
} else {
  Info "Reusing storage account '$StorageAccountName'"
}
$key = (az storage account keys list -n $StorageAccountName -g $StateResourceGroup --query "[0].value" -o tsv)
Info "Ensuring container '$StateContainer'"
az storage container create -n $StateContainer --account-name $StorageAccountName --account-key $key | Out-Null

# --- 5. GitHub environments + secrets --------------------------------------
Info "Ensuring GitHub environments 'dev' and 'prod'"
gh api -X PUT "repos/$Repo/environments/dev"  | Out-Null
gh api -X PUT "repos/$Repo/environments/prod" | Out-Null

Info "Setting repository secrets"
gh secret set AZURE_CLIENT_ID        -R $Repo -b $AppId
gh secret set AZURE_TENANT_ID        -R $Repo -b $TenantId
gh secret set AZURE_SUBSCRIPTION_ID  -R $Repo -b $SubscriptionId
gh secret set TFSTATE_RESOURCE_GROUP -R $Repo -b $StateResourceGroup
gh secret set TFSTATE_STORAGE_ACCOUNT -R $Repo -b $StorageAccountName
gh secret set TFSTATE_CONTAINER      -R $Repo -b $StateContainer

# --- Summary ----------------------------------------------------------------
Write-Host ""
Write-Host "Bootstrap complete." -ForegroundColor Green
Write-Host "  AZURE_CLIENT_ID        = $AppId"
Write-Host "  AZURE_TENANT_ID        = $TenantId"
Write-Host "  AZURE_SUBSCRIPTION_ID  = $SubscriptionId"
Write-Host "  TFSTATE_RESOURCE_GROUP = $StateResourceGroup"
Write-Host "  TFSTATE_STORAGE_ACCOUNT = $StorageAccountName"
Write-Host "  TFSTATE_CONTAINER      = $StateContainer"
Write-Host ""
Write-Host "Next: merge to main, then run Actions -> 'Terraform Apply' -> Run workflow."
