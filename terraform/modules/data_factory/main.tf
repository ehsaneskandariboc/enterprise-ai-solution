resource "azurerm_data_factory" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # System-assigned managed identity for secure, secret-less access to data
  # sources, Key Vault, and storage.
  identity {
    type = "SystemAssigned"
  }

  managed_virtual_network_enabled = var.enable_managed_virtual_network
  public_network_enabled          = var.public_network_enabled

  # Optional Git (GitHub) integration so pipeline authoring is source-controlled.
  dynamic "github_configuration" {
    for_each = var.github_configuration == null ? [] : [var.github_configuration]

    content {
      account_name    = github_configuration.value.account_name
      branch_name     = github_configuration.value.branch_name
      git_url         = github_configuration.value.git_url
      repository_name = github_configuration.value.repository_name
      root_folder     = github_configuration.value.root_folder
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "adf" {
  name                       = "diag-adf"
  target_resource_id         = azurerm_data_factory.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ActivityRuns"
  }

  enabled_log {
    category = "PipelineRuns"
  }

  enabled_log {
    category = "TriggerRuns"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
