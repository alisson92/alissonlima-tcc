mock_provider "azurerm" {}

variables {
  environment         = "teste"
  location            = "East US"
  resource_group_name = "rg-tcc-teste"
  private_subnet_ids  = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tcc-teste/providers/Microsoft.Network/virtualNetworks/vnet-teste/subnets/subnet-private-a", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tcc-teste/providers/Microsoft.Network/virtualNetworks/vnet-teste/subnets/subnet-private-b"]
  vm_size             = "Standard_B1s"
  public_key          = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6YgDl8A4rMXOEhmZsx/9H4/Gw1KAjOEsoPdZxKdtRS test-fixture@tcc"
  db_disk_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tcc-teste/providers/Microsoft.Compute/disks/disk-db-data-teste"
  app_server_count    = 2
  tags                = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

run "app_server_count_matches_input" {
  command = plan

  assert {
    condition     = length(azurerm_linux_virtual_machine.app_server) == var.app_server_count
    error_message = "Número de VMs de aplicação não corresponde a var.app_server_count"
  }
}

run "admin_username_standardized_as_ubuntu" {
  command = plan

  # Padronização multicloud: o usuário admin é sempre "ubuntu", igual à AWS.
  assert {
    condition     = alltrue([for vm in azurerm_linux_virtual_machine.app_server : vm.admin_username == "ubuntu"])
    error_message = "VMs de aplicação devem usar admin_username = ubuntu, para paridade com a AWS"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.db_server.admin_username == "ubuntu"
    error_message = "VM de banco de dados deve usar admin_username = ubuntu, para paridade com a AWS"
  }
}
