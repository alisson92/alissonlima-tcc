variable "environment" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "private_subnet_ids" { type = list(string) }

variable "vm_size" {
  description = "Tamanho da VM (Ex: Standard_B1s)."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Usuário administrador das VMs."
  type        = string
  default     = "adminuser"
}

variable "public_key" {
  description = "Conteúdo da chave pública SSH."
  type        = string
}

variable "db_disk_id" {
  description = "ID do Managed Disk para o banco de dados."
  type        = string
}

variable "private_dns_zone_name" {
  description = "Nome da zona de DNS privado na Azure."
  type        = string
}

variable "app_server_count" {
  type    = number
  default = 1
}

variable "tags" { type = map(string) }