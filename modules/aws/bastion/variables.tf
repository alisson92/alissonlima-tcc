variable "public_subnet_id" {
  description = "ID da sub-rede pública onde o Bastion será criado."
  type        = string
}

variable "sg_bastion_id" {
  description = "ID do Security Group para o Bastion Host."
  type        = string
}

variable "ami_id" {
  description = "ID da AMI Ubuntu para o Bastion Host."
  type        = string
}

variable "key_name" {
  description = "Nome do par de chaves EC2 para acesso SSH."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: teste, homol, prod) para composição dos nomes."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado aos recursos do Bastion."
  type        = map(string)
  default     = {}
}