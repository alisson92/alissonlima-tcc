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

#### RECURSOS DO BACKEND ####

# 1. Grupo de Recursos para o Backend
resource "azurerm_resource_group" "terraform_state_rg" {
  name     = "rg-terraform-state"
  location = "eastus"

  lifecycle {
    prevent_destroy = true
  }
}

# 2. Storage Account para guardar o arquivo .tfstate
# O nome deve ser único globalmente, por isso mantemos o padrão 'sttccalissonteste'
resource "azurerm_storage_account" "terraform_state_sa" {
  name                     = "sttccalissonteste"
  resource_group_name      = azurerm_resource_group.terraform_state_rg.name
  location                 = azurerm_resource_group.terraform_state_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Local Redundant Storage (Econômico para o TCC)
  allow_nested_items_to_be_public = false

  ### Proteção contra destruição acidental
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Project   = "TCC-AlissonLima-Azure"
    ManagedBy = "Terraform"
  }
}

# 3. Container Blob (O equivalente ao Bucket S3)
resource "azurerm_storage_container" "terraform_state_container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.terraform_state_sa.name
  container_access_type = "private"
}

/* O intuito deste arquivo main.tf é criar os recursos necessários para o backend remoto na Azure.
   Diferente da AWS, o Azure Storage Account utiliza internamente o recurso de 'Blob Lease' para 
   travar o arquivo de estado durante a execução, dispensando a criação de uma tabela de trava (lock) separada.
   Isso garante que o estado da infraestrutura de aproximadamente 200 containers e diversos clientes 
   seja gerenciado de forma segura e centralizada, essencial para a atuação de um futuro Engenheiro DevOps.
*/