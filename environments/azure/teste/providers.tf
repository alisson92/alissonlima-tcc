terraform {
  required_version = ">= 1.0.0"

  # 1. Definição dos Provedores Necessários
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # 2. Configuração do Backend (Onde o estado da Azure será salvo)
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "alissonlimatcctfstate"
    container_name       = "tfstate"
    key                  = "environments/azure/teste/terraform.tfstate"
  }
}

# 3. Configuração do Provedor Azure
provider "azurerm" {
  features {} # Obrigatório para o Azure
}

# 4. Configuração do Provedor AWS (Para o DNS no Route 53)
provider "aws" {
  region = "us-east-1" 
  # Não precisamos passar as chaves aqui pois o GitHub Actions 
  # injeta automaticamente via variáveis de ambiente (AWS_ACCESS_KEY_ID, etc.)
}