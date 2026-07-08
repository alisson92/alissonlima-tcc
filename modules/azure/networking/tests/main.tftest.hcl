mock_provider "azurerm" {}

variables {
  vnet_cidr_block     = "10.60.0.0/16"
  environment         = "teste"
  location            = "East US"
  resource_group_name = "rg-tcc-teste"
  tags                = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

run "vnet_address_space_matches_input" {
  command = plan

  assert {
    condition     = contains(azurerm_virtual_network.main.address_space, var.vnet_cidr_block)
    error_message = "Address space da VNet não corresponde à variável de entrada"
  }
}

run "private_dns_zone_matches_convention" {
  command = plan

  assert {
    condition     = azurerm_private_dns_zone.internal.name == "internal.alissonlima.dev.br"
    error_message = "Zona de DNS privada interna deve seguir a convenção internal.alissonlima.dev.br"
  }

  assert {
    condition     = azurerm_private_dns_zone_virtual_network_link.internal_link.registration_enabled == true
    error_message = "Auto-registro de VMs no DNS privado deve estar habilitado"
  }
}
