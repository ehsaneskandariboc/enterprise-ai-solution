variable "name" {
  type        = string
  description = "Name of the Key Vault."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "sku_name" {
  type        = string
  description = "Key Vault SKU."
  default     = "standard"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
