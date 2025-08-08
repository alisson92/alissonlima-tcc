variable "public_subnet_id" {
  description = "ID da sub-rede pública onde o Bastion será criado."
  type        = string
}

variable "sg_bastion_id" {
  description = "ID do Security Group para o Bastion Host."
  type        = string
}

variable "ami_id" {
  description = "ID da AMI para o Bastion (Ubuntu)."
  type        = string
}

variable "key_name" {
  description = "Nome do par de chaves EC2 para acesso SSH."
  type        = string
}