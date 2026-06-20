resource "azurerm_storage_account" "func" {
  name                            = substr("stfn${var.name_compact}${var.suffix}", 0, 24)
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

resource "azurerm_service_plan" "func" {
  name                = "plan-func-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "EP1"
  tags                = var.tags
}

resource "azurerm_linux_function_app" "main" {
  name                       = "func-${var.name_prefix}-${var.suffix}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.func.id
  storage_account_name       = azurerm_storage_account.func.name
  storage_account_access_key = azurerm_storage_account.func.primary_access_key
  virtual_network_subnet_id  = var.subnet_id
  https_only                 = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_insights_key               = var.application_insights_key
    application_insights_connection_string = var.app_insights_connection

    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "COSMOS_DB_ENDPOINT"       = var.cosmos_endpoint
    "KEY_VAULT_ID"             = var.key_vault_id
  }

  tags = var.tags
}
