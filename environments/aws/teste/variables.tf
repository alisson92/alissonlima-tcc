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
  description = "Um mapa de tags para ser aplicado nos recursos da rede."
  type        = map(string)
  default     = {} # É uma boa prática dar um default vazio para tornar opcional
}

variable "my_ip" {
  description = "IP pessoal para liberação de acesso SSH no Bastion Host."
  type        = string
}
