output "endpoint" {
  description = "Cosmos DB account endpoint."
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "account_name" {
  description = "Cosmos DB account name."
  value       = azurerm_cosmosdb_account.main.name
}

output "database_name" {
  description = "Cosmos DB SQL database name."
  value       = azurerm_cosmosdb_sql_database.main.name
}

output "container_name" {
  description = "Cosmos DB vector container name."
  value       = azurerm_cosmosdb_sql_container.embeddings.name
}
