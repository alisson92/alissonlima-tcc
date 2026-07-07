# =====================================================================
# ENVIRONMENTS/PROD/BACKEND.TF - ESTADO REMOTO SEGURO (AZURE STORAGE)
# =====================================================================

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "alissonlimatcctfstate"
    container_name       = "tfstate"
    key                  = "environments/azure/prod/terraform.tfstate"
  }
}
