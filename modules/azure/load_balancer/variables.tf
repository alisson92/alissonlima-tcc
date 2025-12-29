variable "resource_group_name" {
  description = "Nome do Resource Group na Azure."
  type        = string
}

variable "location" {
  description = "Localização/Região da Azure."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: teste)."
  type        = string
}

variable "tags" {
  description = "Mapa de tags para os recursos."
  type        = map(string)
  default     = {}
}