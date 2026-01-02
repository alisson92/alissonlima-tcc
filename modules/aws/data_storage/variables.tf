# =====================================================================
# MÓDULO DATA_STORAGE - VARIÁVEIS DE CONFIGURAÇÃO
# =====================================================================

variable "environment" {
  description = "Nome do ambiente (ex: teste, homol, prod) para composição das tags."
  type        = string
}

variable "az" {
  description = "A Zona de Disponibilidade onde o volume será criado (Deve ser a mesma da instância EC2)."
  type        = string
}

variable "volume_size" {
  description = "O tamanho do volume EBS em GB (Ex: 10, 20, 50)."
  type        = number
  default     = 8
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado aos recursos de armazenamento."
  type        = map(string)
  default     = {}
}