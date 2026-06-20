output "id" {
  description = "ID of the Function App."
  value       = azurerm_linux_function_app.main.id
}

output "name" {
  description = "Name of the Function App."
  value       = azurerm_linux_function_app.main.name
}

output "default_hostname" {
  description = "Default hostname of the Function App."
  value       = azurerm_linux_function_app.main.default_hostname
}

output "principal_id" {
  description = "System-assigned identity principal ID."
  value       = azurerm_linux_function_app.main.identity[0].principal_id
}
