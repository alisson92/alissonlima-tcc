variable "vpc_id" {
  description = "ID da VPC onde os Security Groups serão criados."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: teste, homol, prod) para composição das tags Name."
  type        = string
}

variable "my_ip" {
  description = "Endereço IP público pessoal para permitir acesso administrativo direto (Opcional)."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos de segurança."
  type        = map(string)
  default     = {}
}