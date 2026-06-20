resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.name_prefix}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = var.log_analytics_workspace_id
  infrastructure_subnet_id   = var.infrastructure_subnet_id
  tags                       = var.tags
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-aca-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

resource "azurerm_container_app" "api" {
  name                         = "ca-api-${var.name_prefix}"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "api"
      image  = var.container_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "COSMOS_DB_ENDPOINT"
        value = var.cosmos_endpoint
      }

      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.app_insights_connection
      }
    }

    http_scale_rule {
      name                = "http-scaling"
      concurrent_requests = 50
    }
  }

  depends_on = [azurerm_role_assignment.acr_pull]
}
