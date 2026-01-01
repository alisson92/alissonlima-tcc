variable "vpc_cidr_block" {
  description = "Bloco CIDR para a VPC (Ex: 10.50.0.0/16)."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente para composição dos nomes (Ex: teste, homol, prod)."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos da rede."
  type        = map(string)
  default     = {}
}