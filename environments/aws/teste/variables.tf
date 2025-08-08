variable "persist_db_volume" {
  description = "Controla se o volume EBS do banco de dados deve ser protegido contra destruição."
  type        = bool
  default     = true # O padrão, se o pipeline não passar nada, é proteger.
}
