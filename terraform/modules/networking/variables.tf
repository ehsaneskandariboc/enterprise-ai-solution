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

variable "address_space" {
  type        = list(string)
  description = "VNet address space."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
