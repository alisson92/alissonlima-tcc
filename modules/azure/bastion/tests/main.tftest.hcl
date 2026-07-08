mock_provider "azurerm" {}

variables {
  public_subnet_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tcc-teste/providers/Microsoft.Network/virtualNetworks/vnet-teste/subnets/subnet-public-a"
  admin_username      = "ubuntu"
  public_key          = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6YgDl8A4rMXOEhmZsx/9H4/Gw1KAjOEsoPdZxKdtRS test-fixture@tcc"
  environment         = "teste"
  location            = "East US"
  resource_group_name = "rg-tcc-teste"
  tags                = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

run "bastion_uses_expected_admin_username_and_static_public_ip" {
  command = plan

  assert {
    condition     = azurerm_linux_virtual_machine.bastion.admin_username == var.admin_username
    error_message = "Usuário admin da VM do Bastion deve corresponder à variável de entrada"
  }

  assert {
    condition     = azurerm_public_ip.bastion_pip.allocation_method == "Static"
    error_message = "IP público do Bastion deve ser estático, para não mudar o DNS a cada boot"
  }
}
