output "id" {
  description = "Resource ID of the Data Factory."
  value       = azurerm_data_factory.main.id
}

output "name" {
  description = "Name of the Data Factory."
  value       = azurerm_data_factory.main.name
}

output "identity_principal_id" {
  description = "Principal ID of the Data Factory system-assigned managed identity."
  value       = azurerm_data_factory.main.identity[0].principal_id
}
