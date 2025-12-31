terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#### RECURSOS DO BACKEND (PADRÃO TCC) ####

resource "azurerm_resource_group" "terraform_state_rg" {
  name     = "rg-terraform-state"
  location = "eastus"

  lifecycle {
    prevent_destroy = true
  }
}

# Nome adaptado: alissonlimatcctfstate (letras e números apenas)
resource "azurerm_storage_account" "terraform_state_sa" {
  name                     = "alissonlimatcctfstate" 
  resource_group_name      = azurerm_resource_group.terraform_state_rg.name
  location                 = azurerm_resource_group.terraform_state_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Project   = "alissonlima-tcc"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_storage_container" "terraform_state_container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.terraform_state_sa.name
  container_access_type = "private"
}