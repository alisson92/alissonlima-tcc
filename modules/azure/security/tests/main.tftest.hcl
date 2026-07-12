mock_provider "azurerm" {}

variables {
  resource_group_name = "rg-tcc-teste"
  location            = "East US"
  vnet_cidr_block     = "10.60.0.0/16"
  environment         = "teste"
  my_ip               = "203.0.113.10/32"
  tags                = { Project = "tcc" }
  public_subnet_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tcc-teste/providers/Microsoft.Network/virtualNetworks/vnet-teste/subnets/subnet-public-a",
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tcc-teste/providers/Microsoft.Network/virtualNetworks/vnet-teste/subnets/subnet-public-b",
  ]
  private_subnet_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tcc-teste/providers/Microsoft.Network/virtualNetworks/vnet-teste/subnets/subnet-private-a",
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tcc-teste/providers/Microsoft.Network/virtualNetworks/vnet-teste/subnets/subnet-private-b",
  ]
  appgw_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tcc-teste/providers/Microsoft.Network/virtualNetworks/vnet-teste/subnets/subnet-appgw"
}

run "plans_successfully" {
  command = plan
}

run "bastion_nsg_scoped_to_owner_ip" {
  command = plan

  assert {
    condition = anytrue([
      for r in azurerm_network_security_group.bastion.security_rule :
      r.name == "AllowSSHInbound" && r.source_address_prefix == var.my_ip
    ])
    error_message = "NSG do Bastion deve restringir SSH ao IP do proprietário, não a um CIDR aberto"
  }
}

# Invariante de least-privilege: o SSH administrativo ao app tier só pode vir
# de dentro da VNet (via Bastion), nunca de "*"/Internet. A exceção HTTP em
# "*" é um risco aceito e documentado no próprio main.tf (item #4 do
# HARDENING_CHECKLIST.md) por causa do caminho Cloudflare -> Application Gateway.
run "app_nsg_ssh_restricted_to_virtual_network" {
  command = plan

  assert {
    condition = anytrue([
      for r in azurerm_network_security_group.application.security_rule :
      r.name == "AllowSSHFromBastion" && r.source_address_prefix == "VirtualNetwork"
    ])
    error_message = "SSH do app tier deve ficar restrito a VirtualNetwork, nunca aberto para a Internet"
  }
}
