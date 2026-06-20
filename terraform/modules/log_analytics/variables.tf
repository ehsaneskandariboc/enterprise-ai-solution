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

variable "retention_in_days" {
  type        = number
  description = "Log Analytics retention in days."
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
