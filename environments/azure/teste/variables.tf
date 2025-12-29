# =====================================================================
#   ENVIRONMENTS/AZURE/TESTE/VARIABLES.TF - PADRÃO CONSISTENTE TCC
# =====================================================================

variable "persist_db_volume" {
  description = "Controla se o disco gerenciado (Managed Disk) do banco de dados deve ser protegido contra destruição."
  type        = bool
  default     = true # O padrão, se o pipeline não passar nada, é proteger.
}

variable "create_environment" {
  description = "Se for true, cria todos os recursos efêmeros. Se for false, os destrói via count."
  type        = bool
  default     = true
}

variable "environment_name" {
  description = "O nome do ambiente (ex: teste, homol, prod)."
  type        = string
}

variable "vnet_cidr_block" {
  description = "O bloco de IPs para a Virtual Network (VNet) do ambiente Azure."
  type        = string
}

variable "instance_type" {
  description = "O tipo da instância da VM (Standard_B1s, Standard_B2s, etc)."
  type        = string
}

variable "lb_dns_name" {
  description = "O subdomínio a ser criado no DNS para o Load Balancer."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos da rede."
  type        = map(string)
  default     = {} 
}

variable "my_ip" {
  description = "IP pessoal para liberação de acesso SSH no Bastion Host."
  type        = string
}

variable "app_server_count" {
  description = "Número de servidores de aplicação para este ambiente."
  type        = number
  default     = 1
}

# --- ADIÇÕES NECESSÁRIAS PARA O CONTEXTO AZURE ---

variable "location" {
  description = "A região da Azure onde os recursos serão criados (ex: East US)."
  type        = string
  default     = "East US"
}

variable "public_key" {
  description = "Conteúdo da chave pública SSH para acesso às VMs Linux."
  type        = string
}

variable "private_dns_zone_name" {
  description = "O nome da zona de DNS privado (ex: internal.alissonlima.dev.br)."
  type        = string
}