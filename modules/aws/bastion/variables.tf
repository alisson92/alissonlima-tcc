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

# --- Adicione estas duas variáveis que estão faltando ---
variable "zone_id" {
  description = "ID da Public Hosted Zone no Route 53."
  type        = string
}

variable "domain_name" {
  description = "O nome do seu domínio."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: teste)."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos da rede."
  type        = map(string)
  default     = {}
}