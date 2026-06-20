variable "name" {
  type        = string
  description = "Name of the Cosmos DB account."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy into."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "database_name" {
  type        = string
  description = "Name of the SQL database."
  default     = "knowledge"
}

variable "container_name" {
  type        = string
  description = "Name of the vector container."
  default     = "embeddings"
}

variable "vector_dimensions" {
  type        = number
  description = "Embedding vector dimensions."
  default     = 1536
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for diagnostics."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources."
  default     = {}
}
