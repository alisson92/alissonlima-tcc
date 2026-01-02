# =====================================================================
# ENVIRONMENTS/PROD/VARIABLES.TF - DEFINIÇÕES GLOBAIS DO AMBIENTE
# =====================================================================

variable "create_environment" {
  description = "Se for true, cria todos os recursos. Se for false, os destrói (Toggle de custo)."
  type        = bool
  default     = true
}

variable "environment_name" {
  description = "O nome do ambiente (ex: teste, homol, prod)."
  type        = string
}

variable "vpc_cidr_block" {
  description = "O bloco de IPs para a VPC (Ex: 10.70.0.0/16)."
  type        = string
}

variable "instance_type" {
  description = "O tipo da instância EC2 (t3.micro, t3.small, etc)."
  type        = string
}

variable "tags" {
  description = "Um mapa de tags globais para o ambiente de prod."
  type        = map(string)
  default     = {}
}

variable "my_ip" {
  description = "Seu IP público para acesso administrativo via SSH."
  type        = string
}

variable "app_server_count" {
  description = "Número de servidores de aplicação para escalabilidade."
  type        = number
  default     = 1
}

# --- Boas Práticas Adicionais para o TCC ---

variable "ami_id" {
  description = "ID da AMI Ubuntu para garantir consistência entre as instâncias."
  type        = string
  default     = "ami-0a7d80731ae1b2435"
}

variable "key_name" {
  description = "Nome do par de chaves SSH criado no console da AWS."
  type        = string
  default     = "tcc-alisson-key"
}

variable "cloudflare_api_token" {
  description = "Token de API da Cloudflare com permissão de edição de DNS."
  type        = string
  sensitive   = true # Oculta o valor nos logs do GitHub Actions
}

variable "cloudflare_zone_id" {
  description = "O ID da Zona (Zone ID) disponível no painel da Cloudflare para o seu domínio."
  type        = string
}