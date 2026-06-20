output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_id" {
  description = "ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet identity."
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
