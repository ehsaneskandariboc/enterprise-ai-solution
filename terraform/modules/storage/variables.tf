variable "name" {
  type        = string
  description = "Name of the storage account (alphanumeric, <=24 chars)."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
