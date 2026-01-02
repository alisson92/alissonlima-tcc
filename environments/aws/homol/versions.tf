# =====================================================================
# ENVIRONMENTS/HOMOL/VERSIONS.TF - TRAVAMENTO DE VERSÕES (IMUTABILIDADE)
# =====================================================================

terraform {
  # Garante que todos os membros do grupo e o pipeline usem a mesma versão do binário
  required_version = "~> 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Atualizado para uma versão estável de 2025/2026 para suporte total a instâncias T3 e GP3
      version = "~> 5.80.0" 
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0" 
    }
  }
}
