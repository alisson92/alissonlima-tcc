terraform {
  required_version = ">= 1.0.0"

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

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "alissonlimatcctfstate"
    container_name       = "tfstate"
    key                  = "environments/azure/teste/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "aws" {
  region = "us-east-1"
}