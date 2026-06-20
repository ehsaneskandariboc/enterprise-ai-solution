resource "azurerm_cosmosdb_account" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  # Enables native vector search for the NoSQL API (Cosmos DB vector search).
  capabilities {
    name = "EnableNoSQLVectorSearch"
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
}

resource "azurerm_cosmosdb_sql_container" "embeddings" {
  name                = var.container_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/tenantId"]

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    # The embedding vector itself is excluded from the standard index and served
    # by the dedicated vector index below.
    excluded_path {
      path = "/embedding/*"
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "cosmos" {
  name                       = "diag-cosmos"
  target_resource_id         = azurerm_cosmosdb_account.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_metric {
    category = "Requests"
  }
}
