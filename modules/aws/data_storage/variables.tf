variable "environment" {
  type = string
}

# --- VARIÁVEL ADICIONADA/CORRIGIDA ---
variable "db_server_availability_zone" {
  description = "A Zona de Disponibilidade onde o volume do banco de dados será criado."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos da rede."
  type        = map(string)
  default     = {}
}