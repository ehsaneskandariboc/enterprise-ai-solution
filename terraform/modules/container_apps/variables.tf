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

variable "infrastructure_subnet_id" {
  type        = string
  description = "Subnet ID for the Container Apps environment."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID."
}

variable "container_image" {
  type        = string
  description = "Container image to deploy."
}

variable "acr_login_server" {
  type        = string
  description = "ACR login server."
}

variable "acr_id" {
  type        = string
  description = "ACR resource ID (for AcrPull role assignment)."
}

variable "manage_acr_role_assignment" {
  type        = bool
  description = "Whether to create the AcrPull role assignment for the app identity."
  default     = true
}

variable "cosmos_endpoint" {
  type        = string
  description = "Cosmos DB endpoint."
}

variable "app_insights_connection" {
  type        = string
  description = "Application Insights connection string."
  sensitive   = true
}

variable "min_replicas" {
  type        = number
  description = "Minimum number of replicas."
  default     = 1
}

variable "max_replicas" {
  type        = number
  description = "Maximum number of replicas."
  default     = 10
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
