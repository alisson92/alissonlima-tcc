# =====================================================================
#   VARIABLES.TF - MÓDULO BASTION AZURE (VERSÃO LIMPA E INDEPENDENTE)
# =====================================================================

variable "public_subnet_id" {
  description = "ID da sub-rede pública na VNet Azure onde o Bastion será alocado."
  type        = string
}

variable "admin_username" {
  description = "Usuário padrão para login via SSH na VM do Bastion (Padronizado como 'ubuntu')."
  type        = string
}

variable "public_key" {
  description = "Conteúdo da chave pública SSH para autorizar o acesso à VM."
  type        = string
}

variable "environment" {
  description = "O nome do ambiente atual (ex: teste, homol, prod) para fins de nomenclatura."
  type        = string
}

variable "location" {
  description = "A região da Azure onde o Bastion Host será provisionado."
  type        = string
}

variable "resource_group_name" {
  description = "O nome do Resource Group que conterá os recursos do Bastion."
  type        = string
}

variable "tags" {
  description = "Mapeamento de tags para organização e auditoria de recursos."
  type        = map(string)
  default     = {}
}

# REMOVIDO: variable "domain_name" 
# Justificativa: A gestão de DNS agora é centralizada no ambiente de teste
# utilizando o provedor Azure DNS nativo, removendo a dependência do Route 53.