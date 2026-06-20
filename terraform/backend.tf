# Remote state backend.
#
# Values are supplied at init time via `-backend-config` (see CI workflows and
# terraform/README.md) so that no subscription-specific data is committed.
#
#   terraform init \
#     -backend-config="resource_group_name=<rg>" \
#     -backend-config="storage_account_name=<sa>" \
#     -backend-config="container_name=tfstate" \
#     -backend-config="key=enterprise-ai-<env>.tfstate"
terraform {
  backend "azurerm" {}
}
