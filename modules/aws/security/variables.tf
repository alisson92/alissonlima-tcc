variable "vpc_id" {
  description = "ID da VPC onde os Security Groups serão criados."
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