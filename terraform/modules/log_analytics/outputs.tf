output "workspace_id" {
  description = "ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.main.id
}

output "instrumentation_key" {
  description = "Application Insights instrumentation key."
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "Application Insights connection string."
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}
