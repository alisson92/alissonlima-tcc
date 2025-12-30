terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    # ADICIONE A CLOUDFLARE AQUI
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Configuração do Provedor Cloudflare
provider "cloudflare" {
  api_token = var.cloudflare_api_token 
}

provider "azurerm" {
  features {}
}