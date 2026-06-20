# Bootstrap scripts

One-time setup that wires up **passwordless OIDC auth** between GitHub Actions
and Azure, plus the **remote Terraform state** backend and the **repo secrets**
that `terraform-plan.yml` / `terraform-apply.yml` consume.

You only need to run **one** of these (they do the same thing):

| Script | Run it from |
|--------|-------------|
| `bootstrap-azure-oidc.ps1` | Windows / PowerShell (local) |
| `bootstrap-azure-oidc.sh`  | bash / Azure Cloud Shell / Linux / macOS |

## Prerequisites

- **Azure CLI** logged in: `az login`
- **GitHub CLI** logged in with admin on this repo: `gh auth login`
- Your account can **create Entra app registrations** and **assign subscription
  roles** (Owner, or Contributor + User Access Administrator / a custom role with
  `Microsoft.Authorization/roleAssignments/write`).

> ⚠️ If `az` reports `AADSTS50173` (token revoked / password changed), run
> `az login` again to refresh credentials before running the script.

## What it creates (idempotent — safe to re-run)

1. Entra **app registration** + **service principal** (`gh-enterprise-ai-oidc`).
2. **Federated credentials** for:
   - `pull_request` → used by the plan workflow
   - `ref:refs/heads/main` → push-to-main
   - `environment:dev` and `environment:prod` → used by the apply workflow
3. **Contributor** + **User Access Administrator** on the subscription (the
   latter is required because Terraform creates `AcrPull` role assignments).
4. Resource group + storage account + `tfstate` container for **remote state**.
5. GitHub **environments** `dev` and `prod`.
6. Repo **secrets**: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`,
   `AZURE_SUBSCRIPTION_ID`, `TFSTATE_RESOURCE_GROUP`, `TFSTATE_STORAGE_ACCOUNT`,
   `TFSTATE_CONTAINER`.

## Usage

PowerShell:

```powershell
az login
gh auth login
./scripts/bootstrap-azure-oidc.ps1
# optional overrides:
./scripts/bootstrap-azure-oidc.ps1 -Location westeurope -SubscriptionId <sub-guid>
```

bash:

```bash
az login
gh auth login
chmod +x scripts/bootstrap-azure-oidc.sh
./scripts/bootstrap-azure-oidc.sh
# optional overrides:
LOCATION=westeurope SUBSCRIPTION_ID=<guid> ./scripts/bootstrap-azure-oidc.sh
```

## After running

1. Merge this branch into `main` (so the apply workflow is on the default branch).
2. Go to **Actions → Terraform Apply → Run workflow** and pick `dev` (or `prod`).

That run provisions the full environment.
