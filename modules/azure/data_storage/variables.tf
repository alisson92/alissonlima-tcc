variable "environment" {
  description = "Ambiente (ex: teste, homol, prod)."
  type        = string
}

variable "location" {
  description = "Região da Azure."
  type        = string
}

variable "resource_group_name" {
  description = "Nome do Resource Group."
  type        = string
}

variable "disk_size_gb" {
  description = "Tamanho do disco em GB."
  type        = number
  default     = 10
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos."
  type        = map(string)
  default     = {}
}