mock_provider "azurerm" {}

variables {
  environment         = "teste"
  location            = "East US"
  resource_group_name = "rg-tcc-teste"
  disk_size_gb        = 20
  tags                = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

run "disk_size_matches_input" {
  command = plan

  assert {
    condition     = azurerm_managed_disk.db_data.disk_size_gb == var.disk_size_gb
    error_message = "Tamanho do disco gerenciado não corresponde à variável de entrada"
  }
}
