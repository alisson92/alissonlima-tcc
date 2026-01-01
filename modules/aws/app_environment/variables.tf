variable "environment" {
  description = "Nome do ambiente (teste, homol, prod) para composição dos nomes."
  type        = string
}

variable "private_subnet_ids" {
  description = "LISTA de IDs das sub-redes privadas onde os servidores serão criados."
  type        = list(string)
}

variable "sg_application_id" {
  description = "ID do Security Group unificado para a aplicação."
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2 para os servidores do ambiente (Ex: t3.micro)."
  type        = string
}

variable "ami_id" {
  description = "ID da Amazon Machine Image (AMI) Ubuntu para os servidores."
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

variable "db_server_availability_zone" {
  description = "A Zona de Disponibilidade para o servidor de banco, necessária para alinhar com o volume EBS."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos."
  type        = map(string)
  default     = {}
}

variable "app_server_count" {
  description = "O número de servidores de aplicação a serem criados (Escalabilidade)."
  type        = number
  default     = 1
}