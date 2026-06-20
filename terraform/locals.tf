locals {
  name_prefix = "${var.project}-${var.environment}"

  # Globally-unique, alphanumeric-only base for resources that disallow hyphens
  # (storage accounts, ACR, etc.).
  name_compact = "${var.project}${var.environment}"

  common_tags = merge(
    {
      project     = var.project
      environment = var.environment
      managedBy   = "terraform"
      workload    = "enterprise-ai"
    },
    var.tags,
  )
}
