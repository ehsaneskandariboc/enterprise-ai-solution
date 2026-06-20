#!/usr/bin/env bash
#
# One-time bootstrap of Azure OIDC (workload identity) + GitHub secrets so the
# Terraform CI/CD workflows in this repo can authenticate to Azure with no
# long-lived credentials.
#
# Idempotent: creates or reuses the app registration, federated credentials,
# role assignments, remote-state storage, GitHub environments, and repo secrets.
#
# Prerequisites:
#   - Azure CLI logged in:   az login
#   - GitHub CLI logged in:  gh auth login   (account must admin this repo)
#   - Permission to create Entra apps and assign subscription roles
#
# Usage:
#   ./scripts/bootstrap-azure-oidc.sh
#   LOCATION=westeurope SUBSCRIPTION_ID=<guid> ./scripts/bootstrap-azure-oidc.sh
#
set -euo pipefail

REPO="${REPO:-ehsaneskandariboc/enterprise-ai-solution}"
APP_NAME="${APP_NAME:-gh-enterprise-ai-oidc}"
LOCATION="${LOCATION:-eastus}"
STATE_RG="${STATE_RG:-rg-entai-tfstate}"
STATE_CONTAINER="${STATE_CONTAINER:-tfstate}"
SUBSCRIPTION_ID="${SUBSCRIPTION_ID:-$(az account show --query id -o tsv)}"
STORAGE_ACCOUNT="${STORAGE_ACCOUNT:-}"

info() { printf '==> %s\n' "$1"; }

az account set --subscription "$SUBSCRIPTION_ID"
TENANT_ID="$(az account show --query tenantId -o tsv)"
info "Subscription : $SUBSCRIPTION_ID"
info "Tenant       : $TENANT_ID"
info "Repo         : $REPO"

# 1. App registration + service principal
APP_ID="$(az ad app list --display-name "$APP_NAME" --query '[0].appId' -o tsv)"
if [[ -z "$APP_ID" ]]; then
  info "Creating app registration '$APP_NAME'"
  APP_ID="$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)"
else
  info "Reusing app registration '$APP_NAME' ($APP_ID)"
fi

SP_OBJECT_ID="$(az ad sp show --id "$APP_ID" --query id -o tsv 2>/dev/null || true)"
if [[ -z "$SP_OBJECT_ID" ]]; then
  info "Creating service principal"
  SP_OBJECT_ID="$(az ad sp create --id "$APP_ID" --query id -o tsv)"
fi

# 2. Federated credentials
declare -A SUBJECTS=(
  [gh-pull-request]="repo:${REPO}:pull_request"
  [gh-branch-main]="repo:${REPO}:ref:refs/heads/main"
  [gh-env-dev]="repo:${REPO}:environment:dev"
  [gh-env-prod]="repo:${REPO}:environment:prod"
)
EXISTING_FIC="$(az ad app federated-credential list --id "$APP_ID" --query '[].name' -o tsv || true)"
for name in "${!SUBJECTS[@]}"; do
  if grep -qx "$name" <<<"$EXISTING_FIC"; then
    info "Federated credential '$name' already exists"
    continue
  fi
  info "Creating federated credential '$name'"
  az ad app federated-credential create --id "$APP_ID" --parameters "{
    \"name\":\"$name\",
    \"issuer\":\"https://token.actions.githubusercontent.com\",
    \"subject\":\"${SUBJECTS[$name]}\",
    \"audiences\":[\"api://AzureADTokenExchange\"]
  }" >/dev/null
done

# 3. Role assignments
for role in "Contributor" "User Access Administrator"; do
  info "Ensuring role '$role' on the subscription"
  az role assignment create \
    --assignee-object-id "$SP_OBJECT_ID" \
    --assignee-principal-type ServicePrincipal \
    --role "$role" \
    --scope "/subscriptions/$SUBSCRIPTION_ID" >/dev/null 2>&1 || true
done

# 4. Remote state storage
info "Ensuring resource group '$STATE_RG'"
az group create -n "$STATE_RG" -l "$LOCATION" >/dev/null

if [[ -z "$STORAGE_ACCOUNT" ]]; then
  STORAGE_ACCOUNT="stentaitf$(openssl rand -hex 3)"   # <= 24 chars
fi
if ! az storage account show -n "$STORAGE_ACCOUNT" -g "$STATE_RG" >/dev/null 2>&1; then
  info "Creating storage account '$STORAGE_ACCOUNT'"
  az storage account create \
    -n "$STORAGE_ACCOUNT" -g "$STATE_RG" -l "$LOCATION" \
    --sku Standard_LRS --min-tls-version TLS1_2 --allow-blob-public-access false >/dev/null
else
  info "Reusing storage account '$STORAGE_ACCOUNT'"
fi
KEY="$(az storage account keys list -n "$STORAGE_ACCOUNT" -g "$STATE_RG" --query '[0].value' -o tsv)"
info "Ensuring container '$STATE_CONTAINER'"
az storage container create -n "$STATE_CONTAINER" --account-name "$STORAGE_ACCOUNT" --account-key "$KEY" >/dev/null

# 5. GitHub environments + secrets
info "Ensuring GitHub environments 'dev' and 'prod'"
gh api -X PUT "repos/$REPO/environments/dev"  >/dev/null
gh api -X PUT "repos/$REPO/environments/prod" >/dev/null

info "Setting repository secrets"
gh secret set AZURE_CLIENT_ID         -R "$REPO" -b "$APP_ID"
gh secret set AZURE_TENANT_ID         -R "$REPO" -b "$TENANT_ID"
gh secret set AZURE_SUBSCRIPTION_ID   -R "$REPO" -b "$SUBSCRIPTION_ID"
gh secret set TFSTATE_RESOURCE_GROUP  -R "$REPO" -b "$STATE_RG"
gh secret set TFSTATE_STORAGE_ACCOUNT -R "$REPO" -b "$STORAGE_ACCOUNT"
gh secret set TFSTATE_CONTAINER       -R "$REPO" -b "$STATE_CONTAINER"

cat <<EOF

Bootstrap complete.
  AZURE_CLIENT_ID         = $APP_ID
  AZURE_TENANT_ID         = $TENANT_ID
  AZURE_SUBSCRIPTION_ID   = $SUBSCRIPTION_ID
  TFSTATE_RESOURCE_GROUP  = $STATE_RG
  TFSTATE_STORAGE_ACCOUNT = $STORAGE_ACCOUNT
  TFSTATE_CONTAINER       = $STATE_CONTAINER

Next: merge to main, then run Actions -> 'Terraform Apply' -> Run workflow.
EOF
