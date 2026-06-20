output "environment_id" {
  description = "ID of the Container Apps environment."
  value       = azurerm_container_app_environment.main.id
}

output "app_fqdn" {
  description = "FQDN of the API Container App."
  value       = azurerm_container_app.api.ingress[0].fqdn
}

output "identity_id" {
  description = "User-assigned identity ID used by the Container App."
  value       = azurerm_user_assigned_identity.app.id
}
