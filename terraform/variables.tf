variable "subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy into."
}

variable "environment" {
  type        = string
  description = "Deployment environment name (e.g. dev, staging, prod)."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "eastus"
}

variable "project" {
  type        = string
  description = "Short project name used as a prefix for resource naming."
  default     = "entai"

  validation {
    condition     = can(regex("^[a-z0-9]{2,12}$", var.project))
    error_message = "project must be 2-12 lowercase alphanumeric characters."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to all resources."
  default     = {}
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network."
  default     = ["10.40.0.0/16"]
}

variable "aks_node_count" {
  type        = number
  description = "Initial number of nodes in the AKS default node pool."
  default     = 2
}

variable "aks_min_node_count" {
  type        = number
  description = "Minimum AKS node count when autoscaling."
  default     = 2
}

variable "aks_max_node_count" {
  type        = number
  description = "Maximum AKS node count when autoscaling."
  default     = 5
}

variable "aks_node_vm_size" {
  type        = string
  description = "VM size for AKS nodes."
  default     = "Standard_D4s_v5"
}

variable "container_app_image" {
  type        = string
  description = "Container image for the inference/API Container App."
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "cosmos_vector_dimensions" {
  type        = number
  description = "Embedding vector dimensions for Cosmos DB vector search."
  default     = 1536
}
