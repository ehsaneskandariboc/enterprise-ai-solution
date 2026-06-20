output "id" {
  description = "ID of the storage account."
  value       = azurerm_storage_account.main.id
}

output "name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.main.name
}

output "primary_connection_string" {
  description = "Primary connection string of the storage account."
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}
