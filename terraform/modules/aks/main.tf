resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = "aks-${var.name_prefix}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                 = "system"
    vm_size              = var.node_vm_size
    vnet_subnet_id       = var.subnet_id
    node_count           = var.node_count
    auto_scaling_enabled = true
    min_count            = var.min_node_count
    max_count            = var.max_node_count
    orchestrator_version = var.kubernetes_version

    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  azure_policy_enabled = true

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                            = var.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}
