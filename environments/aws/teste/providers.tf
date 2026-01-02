# =====================================================================
# ENVIRONMENTS/TESTE/PROVIDERS.TF - PROVEDORES DE SERVIÇO
# =====================================================================

# Configuração do Provedor AWS
provider "aws" {
  region = "us-east-1"
}

# Configuração do Provedor Cloudflare (Novo!)
# Isso permitirá que o Terraform atualize seu DNS automaticamente
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}