# =====================================================================
# MÓDULO LOAD BALANCER - VARIÁREIS DE CONFIGURAÇÃO
# =====================================================================

variable "vpc_id" {
  description = "ID da VPC onde o Load Balancer e o Target Group serão criados."
  type        = string
}

variable "public_subnet_ids" {
  description = "Lista de IDs das sub-redes públicas (O ALB exige pelo menos duas subnets em AZs diferentes)."
  type        = list(string)
}

variable "sg_alb_id" {
  description = "ID do Security Group para o Load Balancer (Permite tráfego das portas 80/443)."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: teste, homol, prod) para composição dos nomes dinâmicos."
  type        = string
}

variable "app_server_ids" {
  description = "Lista de IDs das instâncias EC2 de aplicação para registro no Target Group."
  type        = list(string)
}

variable "tags" {
  description = "Um mapa de tags para ser aplicado nos recursos do Load Balancer."
  type        = map(string)
  default     = {}
}