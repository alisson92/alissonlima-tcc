variable "environment" {
  description = "Nome do ambiente (teste, homol, prod)."
  type        = string
}

variable "private_subnet_id" {
  description = "ID da sub-rede privada onde os servidores serão criados."
  type        = string
}

variable "sg_app_id" {
  description = "ID do Security Group para os servidores de aplicação."
  type        = string
}

variable "sg_db_id" {
  description = "ID do Security Group para os servidores de banco de dados."
  type        = string
}

variable "instance_type_app" {
  description = "Tipo da instância EC2 para o servidor de aplicação."
  type        = string
  default     = "t3.micro"
}

variable "instance_type_db" {
  description = "Tipo da instância EC2 para o servidor de banco de dados."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "ID da Amazon Machine Image (AMI) para usar nos servidores (ex: Ubuntu)."
  type        = string
}

variable "key_name" {
  description = "Nome do par de chaves EC2 para acesso SSH."
  type        = string
}
