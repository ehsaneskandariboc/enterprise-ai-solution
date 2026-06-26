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

variable "function_plan_sku" {
  type        = string
  description = "App Service plan SKU for the Function App. Y1 = Consumption (serverless, no dedicated-VM quota); EP1+ = Elastic Premium (requires VM quota, enables VNet integration)."
  default     = "Y1"
}

variable "deploy_function_app" {
  type        = bool
  description = "Whether to deploy the Azure Functions app. Requires App Service (Microsoft.Web) compute quota in the target region; set false where that quota is unavailable."
  default     = true
}

variable "cosmos_vector_dimensions" {
  type        = number
  description = "Embedding vector dimensions for Cosmos DB vector search."
  default     = 1536
}

variable "adf_enable_managed_virtual_network" {
  type        = bool
  description = "Whether to enable the Azure Data Factory managed virtual network for network-isolated integration runtimes."
  default     = false
}

variable "adf_public_network_enabled" {
  type        = bool
  description = "Whether the Azure Data Factory is reachable over the public network. Set to false when using private endpoints only."
  default     = true
}

variable "adf_github_configuration" {
  type = object({
    account_name    = string
    branch_name     = string
    git_url         = string
    repository_name = string
    root_folder     = string
  })
  description = "Optional GitHub source-control integration for Data Factory pipeline authoring. Leave null to use Live (factory) mode."
  default     = null
}

variable "manage_acr_role_assignments" {
  type        = bool
  description = "Whether Terraform manages the AcrPull role assignments for AKS and Container Apps. This requires the deploying identity to have role-assignment write permission (e.g. User Access Administrator or Owner). Set to false when that permission is unavailable; grant AcrPull out-of-band instead."
  default     = true
}
