variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for AKS nodes."
}

variable "node_count" {
  type        = number
  description = "Initial node count."
  default     = 2
}

variable "min_node_count" {
  type        = number
  description = "Minimum node count for autoscaling."
  default     = 2
}

variable "max_node_count" {
  type        = number
  description = "Maximum node count for autoscaling."
  default     = 5
}

variable "node_vm_size" {
  type        = string
  description = "VM size for the default node pool."
  default     = "Standard_D4s_v5"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version (null = AKS default)."
  default     = null
}

variable "acr_id" {
  type        = string
  description = "ACR resource ID for AcrPull role assignment."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for monitoring."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
