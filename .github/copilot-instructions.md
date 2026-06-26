🔹 Purpose of Repository
This repository provisions CTR (Central Transaction Repository) Azure infrastructure using Terraform, including:

Azure resources via azurerm
Identity via azuread
CI/CD via GitHub Actions
Multi-environment deployment (dev/test/prod)

🔹 Core Principles
1. Infrastructure as Code Discipline

All changes must go through PR review
No manual changes in Azure (enforced drift control)
Use Terraform plan before apply


CI/CD pipelines enforce automated Terraform workflows for safe deployments 


2. Environment Isolation

Separate configs per environment:
environments/
  dev/
  test1/
  test2/
  prod/


Never mix env-specific values in shared modules


Separation improves maintainability and avoids config drift 


3. Modular Design


Reusable components live under:
modules/
  networking/
  compute/
  data/
  monitoring/



Modules must be:

Idempotent
Parameterized
Environment-agnostic




4. Remote State & Safety

Azure Storage backend required
State locking enabled


Remote state prevents overwrite and enables team collaboration 


5. CI/CD Governance (GitHub Actions)
Each PR must:

✅ Run terraform fmt
✅ Run terraform validate
✅ Run security scans (tfsec / checkov)
✅ Generate terraform plan
❌ NOT auto-apply

Each merge:

✅ Apply only after approval (especially prod)


Approval gates reduce risk in production deployments 

Life cycle management for data service is a must.


6. Security & Identity

Use:

Managed Identity / OIDC (no secrets)
Least privilege RBAC
Azure Key Vault for secrets




7. FinOps Awareness (Very relevant for CTR)


Every resource must include:

environment
cost_center
owner



Use tagging enforcement
