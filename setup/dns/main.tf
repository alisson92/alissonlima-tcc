# setup/dns/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Ou a região de sua preferência
}

# Cria a Public Hosted Zone para o seu domínio
resource "aws_route53_zone" "primary" {
  name = "alissonlima.dev.br"
}

# Exibe os nameservers criados pela AWS como uma saída
output "aws_nameservers" {
  description = "Nameservers da AWS para configurar no Registro.br"
  value       = aws_route53_zone.primary.name_servers
}
