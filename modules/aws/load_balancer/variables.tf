variable "vpc_id" {
  description = "ID da VPC onde o Load Balancer será criado."
  type        = string
}

variable "public_subnet_ids" {
  description = "Lista de IDs das sub-redes públicas para o Load Balancer."
  type        = list(string)
}

variable "sg_alb_id" {
  description = "ID do Security Group para anexar ao Load Balancer."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: teste)."
  type        = string
}

variable "certificate_arn" {
  description = "ARN do certificado SSL do ACM para o listener HTTPS."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos da rede."
  type        = map(string)
  default     = {}
}
