variable "name" {
  type        = string
  description = "Name of the Azure Data Factory instance."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for diagnostics."
}

variable "enable_managed_virtual_network" {
  type        = bool
  description = "Whether to enable the Data Factory managed virtual network for secure, network-isolated integration runtimes."
  default     = false
}

variable "public_network_enabled" {
  type        = bool
  description = "Whether the Data Factory is reachable over the public network. Set to false when using private endpoints only."
  default     = true
}

variable "github_configuration" {
  type = object({
    account_name    = string
    branch_name     = string
    git_url         = string
    repository_name = string
    root_folder     = string
  })
  description = "Optional GitHub source-control integration for pipeline authoring. Leave null to use Live (factory) mode."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
