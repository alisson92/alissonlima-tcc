variable "environment" {
  description = "Nome do ambiente (ex: teste, homol, prod)."
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

variable "private_subnet_ids" {
  description = "Lista de IDs das sub-redes privadas onde as VMs serão criadas."
  type        = list(string)
}

variable "vm_size" {
  description = "Tamanho da VM (Ex: Standard_B1s_v2)."
  type        = string
  default     = "Standard_B1s_v2"
}

variable "public_key" {
  description = "Conteúdo da chave pública SSH."
  type        = string
}

variable "db_disk_id" {
  description = "ID do Managed Disk para o banco de dados."
  type        = string
}

variable "app_server_count" {
  description = "Quantidade de servidores de aplicação a serem criados."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos."
  type        = map(string)
}