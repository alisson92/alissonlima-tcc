variable "resource_group_name" {
  description = "Nome do Resource Group onde os NSGs serão criados."
  type        = string
}

variable "location" {
  description = "Região da Azure (Ex: East US)."
  type        = string
}

variable "vnet_cidr_block" {
  description = "O bloco CIDR da VNet para usar nas regras de segurança."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: teste, homol, prod) para usar nas tags."
  type        = string
}

variable "my_ip" {
  description = "Seu endereço IP público para permitir acesso SSH ao Bastion Host."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos."
  type        = map(string)
  default     = {}
}

variable "public_subnet_ids" {
  description = "Lista de IDs das sub-redes públicas vindas do módulo de networking."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Lista de IDs das sub-redes privadas vindas do módulo de networking."
  type        = list(string)
}