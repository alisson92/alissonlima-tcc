# Configuração do Provedor Cloudflare
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Configuração do Provedor Azure
provider "azurerm" {
  features {}
}

# Configuração do Provedor AWS
provider "aws" {
  region = "us-east-1"
}