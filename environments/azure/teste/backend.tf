terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state" # Crie este RG manualmente antes
    storage_account_name = "alissonlimatcctfstate"  # Nome único global
    container_name       = "tfstate"
    key                  = "environments/azure/teste/terraform.tfstate"
  }
}