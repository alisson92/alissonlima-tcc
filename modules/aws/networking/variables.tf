variable "vpc_cidr_block" {
  description = "Bloco CIDR para a VPC."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: teste, homol, prod)."
  type        = string
}

variable "aws_region" {
  description = "Região da AWS para criar os recursos."
  type        = string
}
