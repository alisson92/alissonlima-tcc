variable "environment" {
  description = "Nome do ambiente (teste, homol, prod)."
  type        = string
}

variable "private_subnet_id" {
  description = "ID da sub-rede privada onde os servidores serao criados."
  type        = string
}

variable "sg_application_id" {
  description = "ID do Security Group unificado para a aplicacao."
  type        = string
}

variable "instance_type" { # <-- MANTIVEMOS APENAS A GENÉRICA
  description = "Tipo da instancia EC2 para os servidores do ambiente."
  type        = string
}

variable "ami_id" {
  description = "ID da Amazon Machine Image (AMI) para usar nos servidores (ex: Ubuntu)."
  type        = string
}

variable "key_name" {
  description = "Nome do par de chaves EC2 para acesso SSH."
  type        = string
}

variable "db_volume_id" {
  description = "ID do volume EBS a ser anexado ao servidor de banco de dados."
  type        = string
}

variable "private_zone_id" {
  description = "ID da Private Hosted Zone no Route 53."
  type        = string
}

variable "private_domain_name" {
  description = "O nome do domínio privado (ex: internal.alissonlima.dev.br)."
  type        = string
}

variable "db_server_availability_zone" {
  description = "A Zona de Disponibilidade para o servidor de banco de dados, para alinhar com o volume EBS."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos."
  type        = map(string)
  default     = {}
}