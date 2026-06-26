# Terraform AzureRM Best Practices

## 🎯 Objective
Ensure all Azure resources provisioned via Terraform follow Microsoft-recommended and CTR-aligned standards for reliability, scalability, and maintainability.

---

## ✅ Required Checks

### 1. Resource Configuration
- Use the latest stable `azurerm` provider version
- Explicitly define:
  - `location`
  - `resource_group_name`
- Avoid implicit defaults

---

### 2. Naming Conventions
- Follow standardized naming examples (e.g., `ctr-prod-weu-rg`, `ctr-prod-weu-capenv`)
- Use consistent abbreviations across modules

---

### 3. SKU & Tier Selection
- Avoid Premium SKUs in non-production environments unless justified
- Prefer cost-efficient SKUs (e.g., Standard tiers where applicable)

---

### 4. Networking & Security
- Enforce:
- Private endpoints where possible
- NSGs for subnet protection
- Avoid public exposure unless required

---

### 5. Monitoring & Diagnostics
- All resources must include:
- Diagnostic settings
- Log Analytics integration

---

### 6. State Management
- Use remote backend (Azure Storage)
- Enable state locking

---

## ❌ Anti-Patterns

- Hardcoded values instead of variables
- Inline resource duplication
- Missing location or naming standards
- Direct public endpoint exposure

---

## ✅ Agent Expected Behavior

The agent should:
- Flag non-compliant resources
- Suggest improved configurations
- Highlight cost or security risks
