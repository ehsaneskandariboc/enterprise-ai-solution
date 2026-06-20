output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet."
  value       = azurerm_subnet.aks.id
}

output "container_apps_subnet_id" {
  description = "ID of the Container Apps infrastructure subnet."
  value       = azurerm_subnet.container_apps.id
}

output "functions_subnet_id" {
  description = "ID of the Functions integration subnet."
  value       = azurerm_subnet.functions.id
}

output "private_endpoints_subnet_id" {
  description = "ID of the private endpoints subnet."
  value       = azurerm_subnet.private_endpoints.id
}
