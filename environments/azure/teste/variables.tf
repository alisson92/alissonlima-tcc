# =====================================================================
#   ENVIRONMENTS/AZURE/TESTE/VARIABLES.TF - PADRÃO CONSISTENTE TCC
# =====================================================================

variable "persist_db_volume" {
  description = "Controla se o disco gerenciado do banco de dados deve ser protegido contra destruição."
  type        = bool
  default     = true
}

variable "create_environment" {
  description = "Se for true, cria todos os recursos efêmeros. Se for false, os destrói."
  type        = bool
  default     = true
}

variable "environment_name" {
  description = "O nome do ambiente (ex: teste, homol, prod)."
  type        = string
  default     = "teste" # Valor padrão para agilizar o deploy
}

variable "vnet_cidr_block" {
  description = "O bloco de IPs para a Virtual Network (VNet) do ambiente Azure."
  type        = string
}

variable "instance_type" {
  description = "O tipo da instância da VM (Standard_B1s, Standard_B2s, etc)."
  type        = string
  default     = "Standard_B1s"
}

variable "lb_dns_name" {
  description = "O subdomínio a ser criado no DNS para o Load Balancer."
  type        = string
  default     = "teste"
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos."
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

# --- AJUSTES PARA PADRONIZAÇÃO E INDEPENDÊNCIA AZURE ---

variable "location" {
  description = "A região da Azure (ex: East US)."
  type        = string
  default     = "East US"
}

variable "public_key" {
  description = "Conteúdo da chave pública SSH para as VMs."
  type        = string
}

variable "admin_username" {
  description = "Usuário padrão para acesso às VMs (Padronizado com AWS)."
  type        = string
  default     = "ubuntu" # Garante a paridade com seu manual de acesso
}

variable "private_dns_zone_name" {
  description = "O nome da zona de DNS privado."
  type        = string
  default     = "internal.alissonlima.dev.br"
}

variable "public_domain_name" {
  description = "O domínio base para a resolução pública na Azure."
  type        = string
  default     = "azure.alissonlima.dev.br"
}