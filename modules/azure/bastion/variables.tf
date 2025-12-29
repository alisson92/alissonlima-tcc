variable "public_subnet_id" {
  description = "ID da sub-rede pública na VNet Azure."
  type        = string
}

# No Azure, o NSG é associado à subnet, então não precisamos passar o ID do SG aqui 
# se a associação já foi feita no módulo de security.

variable "admin_username" {
  description = "Usuário para login na VM."
  type        = string
}

variable "public_key" {
  description = "Conteúdo da chave pública SSH para acesso."
  type        = string
}

variable "domain_name" {
  description = "O nome da zona de DNS pública na Azure."
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: teste, homol, prod)."
  type        = string
}

variable "location" {
  description = "Região da Azure."
  type        = string
}

variable "resource_group_name" {
  description = "Nome do Resource Group."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}