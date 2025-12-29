variable "persist_db_volume" {
  description = "Controla se o volume EBS do banco de dados deve ser protegido contra destruição."
  type        = bool
  default     = true # O padrão, se o pipeline não passar nada, é proteger.
}

variable "create_environment" {
  description = "Se for true, cria todos os recursos efêmeros. Se for false, os destrói."
  type        = bool
  default     = true
}

variable "environment_name" {
  description = "O nome do ambiente (ex: teste, homol, prod)."
  type        = string
  # Sem default! Isso força que a variável seja definida explicitamente no .tfvars
}

variable "vpc_cidr_block" {
  description = "O bloco de IPs para a VPC do ambiente."
  type        = string
  # Sem default! É CRÍTICO que cada ambiente tenha um CIDR diferente.
}

variable "instance_type" {
  description = "O tipo da instância EC2 (t3.micro, t3.small, etc)."
  type        = string
  # Sem default, para garantir que escolhemos um tamanho para cada ambiente.
}

variable "alb_dns_name" {
  description = "O subdomínio a ser criado no Route 53 para o ALB."
  type        = string
}

variable "tags" {
  description = "Tags padrão para aplicar em todos os recursos."
  type        = map(string)
}

# Adicione esta variável em ambos os arquivos variables.tf
variable "my_ip" {
  description = "IP pessoal para liberação de acesso SSH no Bastion Host."
  type        = string
}

variable "app_server_count" {
  description = "Número de servidores de aplicação para este ambiente."
  type        = number
  default     = 1 # Padrão seguro para ambientes não-produtivos.
}