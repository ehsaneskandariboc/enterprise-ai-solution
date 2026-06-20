resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

module "networking" {
  source = "./modules/networking"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

module "log_analytics" {
  source = "./modules/log_analytics"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags
}

module "acr" {
  source = "./modules/acr"

  name                = "acr${local.name_compact}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags
}

module "key_vault" {
  source = "./modules/key_vault"

  name                = "kv-${local.name_prefix}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags
}

module "storage" {
  source = "./modules/storage"

  name                = "st${local.name_compact}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.common_tags
}

module "cosmosdb" {
  source = "./modules/cosmosdb"

  name                       = "cosmos-${local.name_prefix}-${random_string.suffix.result}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  vector_dimensions          = var.cosmos_vector_dimensions
  log_analytics_workspace_id = module.log_analytics.workspace_id
  tags                       = local.common_tags
}

module "function_app" {
  source = "./modules/function_app"

  name_prefix                = local.name_prefix
  name_compact               = local.name_compact
  suffix                     = random_string.suffix.result
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  subnet_id                  = module.networking.functions_subnet_id
  application_insights_key   = module.log_analytics.instrumentation_key
  app_insights_connection    = module.log_analytics.connection_string
  cosmos_endpoint            = module.cosmosdb.endpoint
  key_vault_id               = module.key_vault.id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  tags                       = local.common_tags
}

module "container_apps" {
  source = "./modules/container_apps"

  name_prefix                = local.name_prefix
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  infrastructure_subnet_id   = module.networking.container_apps_subnet_id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  container_image            = var.container_app_image
  acr_login_server           = module.acr.login_server
  acr_id                     = module.acr.id
  cosmos_endpoint            = module.cosmosdb.endpoint
  app_insights_connection    = module.log_analytics.connection_string
  tags                       = local.common_tags
}

module "aks" {
  source = "./modules/aks"

  name_prefix                = local.name_prefix
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  subnet_id                  = module.networking.aks_subnet_id
  node_count                 = var.aks_node_count
  min_node_count             = var.aks_min_node_count
  max_node_count             = var.aks_max_node_count
  node_vm_size               = var.aks_node_vm_size
  acr_id                     = module.acr.id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  tags                       = local.common_tags
}
