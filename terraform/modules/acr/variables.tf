variable "name" {
  type        = string
  description = "Name of the container registry (alphanumeric)."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "sku" {
  type        = string
  description = "ACR SKU."
  default     = "Premium"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
