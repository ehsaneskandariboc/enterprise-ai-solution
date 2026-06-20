# Enterprise AI Solution — Infrastructure

Production-ready, end-to-end Azure infrastructure for an enterprise AI workload,
managed with **Terraform** and deployed via **GitHub Actions**.

## Architecture

The stack provisions the building blocks of an enterprise AI system — ingestion,
embeddings, vector search, APIs, and partner integrations — across serverless and
container platforms:

| Layer | Service | Module |
|-------|---------|--------|
| Networking | Virtual Network + delegated subnets | `modules/networking` |
| Observability | Log Analytics + Application Insights | `modules/log_analytics` |
| Images | Azure Container Registry (Premium) | `modules/acr` |
| Secrets | Azure Key Vault (RBAC, purge protection) | `modules/key_vault` |
| Data lake | Storage Account + containers | `modules/storage` |
| Vector store | Cosmos DB (NoSQL **vector search**) | `modules/cosmosdb` |
| Event/ingestion compute | Azure Functions (Elastic Premium, Python) | `modules/function_app` |
| API / inference | Azure Container Apps (autoscaling) | `modules/container_apps` |
| Orchestration / GPU-ready compute | AKS (autoscaling, Azure CNI) | `modules/aks` |

All services emit diagnostics to a shared Log Analytics workspace, pull images
from a shared ACR via managed identities, and are tagged consistently.

## Layout

```
terraform/
├── versions.tf          # Provider + Terraform version constraints
├── providers.tf         # Provider configuration
├── backend.tf           # Remote state (azurerm) — configured at init time
├── variables.tf         # Root input variables
├── locals.tf            # Naming + common tags
├── main.tf              # Wires the modules together
├── outputs.tf           # Useful endpoints/names
├── environments/        # Per-environment tfvars (dev, prod)
└── modules/             # Reusable building blocks
```

## Prerequisites

- Terraform >= 1.6.0
- An Azure subscription
- A storage account + container for remote state
- A service principal / workload identity with `Contributor` (and `User Access
  Administrator` for the role assignments) on the subscription

## Usage (local)

```bash
cd terraform

terraform init \
  -backend-config="resource_group_name=<state-rg>" \
  -backend-config="storage_account_name=<state-sa>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=enterprise-ai-dev.tfstate"

terraform plan \
  -var="subscription_id=<sub-id>" \
  -var-file="environments/dev.tfvars"

terraform apply \
  -var="subscription_id=<sub-id>" \
  -var-file="environments/dev.tfvars"
```

## CI/CD

Two GitHub Actions workflows under `.github/workflows/`:

- **terraform-plan.yml** — runs `fmt -check`, `init`, `validate`, and `plan` on
  every pull request that touches `terraform/`. The plan is posted back to the PR.
- **terraform-apply.yml** — runs `apply` on push to `main` (and supports manual
  `workflow_dispatch` to pick an environment).

Authentication uses **OIDC** (federated credentials) — no long-lived secrets.
Configure these repository secrets/variables:

| Name | Type | Description |
|------|------|-------------|
| `AZURE_CLIENT_ID` | secret | App registration (workload identity) client ID |
| `AZURE_TENANT_ID` | secret | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | secret | Target subscription ID |
| `TFSTATE_RESOURCE_GROUP` | secret | Resource group of the state storage account |
| `TFSTATE_STORAGE_ACCOUNT` | secret | State storage account name |
| `TFSTATE_CONTAINER` | secret | State container name (e.g. `tfstate`) |

## Notes

- Cosmos DB is created with the `EnableNoSQLVectorSearch` capability so the
  `embeddings` container can store and query embedding vectors
  (`cosmos_vector_dimensions`, default 1536).
- Resource names that must be globally unique (storage, ACR, Cosmos, Function
  App, Key Vault) get a short random suffix.
