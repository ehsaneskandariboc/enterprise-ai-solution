data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                       = substr(var.name, 0, 24)
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  rbac_authorization_enabled = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  tags = var.tags
}
