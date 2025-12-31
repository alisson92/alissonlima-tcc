variable "vnet_cidr_block" {
  description = "Bloco CIDR para a Virtual Network (VNet)."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: teste, homol, prod)."
  type        = string
}

variable "location" {
  description = "Região da Azure para criar os recursos."
  type        = string
}

variable "resource_group_name" {
  description = "Nome do Resource Group onde a rede será criada."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos da rede."
  type        = map(string)
  default     = {}
}
