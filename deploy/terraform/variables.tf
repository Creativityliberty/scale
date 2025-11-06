variable "scw_region" {
  description = "Scaleway region"
  type        = string
  default     = "fr-par"
}

variable "scw_zone" {
  description = "Scaleway zone"
  type        = string
  default     = "fr-par-1"
}

variable "scw_project_id" {
  description = "Scaleway project ID"
  type        = string
}

variable "scw_namespace" {
  description = "Container Registry namespace"
  type        = string
  default     = "mon-saas-ia"
}

variable "node_type" {
  description = "Type de nœuds K8s"
  type        = string
  default     = "DEV1-M"
}

variable "node_count" {
  description = "Nombre initial de nœuds"
  type        = number
  default     = 2
}

variable "min_nodes" {
  type    = number
  default = 1
}

variable "max_nodes" {
  type    = number
  default = 5
}

variable "db_node_type" {
  description = "Type d'instance PostgreSQL"
  type        = string
  default     = "DB-DEV-S"
}

variable "db_password" {
  description = "Mot de passe PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_ha_enabled" {
  description = "Activer HA PostgreSQL"
  type        = bool
  default     = false
}