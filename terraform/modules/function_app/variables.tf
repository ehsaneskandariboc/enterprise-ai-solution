variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
}

variable "name_compact" {
  type        = string
  description = "Compact alphanumeric base name."
}

variable "suffix" {
  type        = string
  description = "Random suffix for globally-unique names."
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
  description = "Subnet ID for VNet integration."
}

variable "application_insights_key" {
  type        = string
  description = "Application Insights instrumentation key."
  sensitive   = true
}

variable "app_insights_connection" {
  type        = string
  description = "Application Insights connection string."
  sensitive   = true
}

variable "cosmos_endpoint" {
  type        = string
  description = "Cosmos DB endpoint."
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault ID."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
