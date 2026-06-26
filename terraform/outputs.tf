output "resource_group_name" {
  description = "Name of the main resource group."
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "Login server of the Azure Container Registry."
  value       = module.acr.login_server
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.cluster_name
}

output "aks_kube_config_command" {
  description = "Command to fetch AKS credentials."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.cluster_name}"
}

output "function_app_default_hostname" {
  description = "Default hostname of the Function App (null when not deployed)."
  value       = var.deploy_function_app ? module.function_app[0].default_hostname : null
}

output "container_app_fqdn" {
  description = "FQDN of the API Container App."
  value       = module.container_apps.app_fqdn
}

output "cosmosdb_endpoint" {
  description = "Cosmos DB account endpoint."
  value       = module.cosmosdb.endpoint
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = module.key_vault.vault_uri
}

output "data_factory_name" {
  description = "Name of the Azure Data Factory."
  value       = module.data_factory.name
}

output "data_factory_id" {
  description = "Resource ID of the Azure Data Factory."
  value       = module.data_factory.id
}
