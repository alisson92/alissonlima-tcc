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

variable "subnet_id" {
  description = "ID da subnet dedicada ao Application Gateway (não pode ter outro recurso associado)."
  type        = string
}

variable "backend_ip_addresses" {
  description = "Lista de IPs privados dos app servers a colocar no backend pool."
  type        = list(string)
}