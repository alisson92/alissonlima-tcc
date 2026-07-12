mock_provider "azurerm" {}

variables {
  resource_group_name  = "rg-tcc-teste"
  location              = "East US"
  environment            = "teste"
  tags                  = { Project = "tcc" }
  subnet_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-tcc-teste/providers/Microsoft.Network/virtualNetworks/vnet-teste/subnets/subnet-appgw"
  backend_ip_addresses  = ["10.60.1.10", "10.60.1.11"]
}

run "plans_successfully" {
  command = plan
}

run "appgw_is_l7_standard_v2_on_port_80" {
  command = plan

  assert {
    condition     = azurerm_application_gateway.main.sku[0].tier == "Standard_v2"
    error_message = "Application Gateway deve usar tier Standard_v2 (L7)"
  }

  assert {
    condition     = azurerm_application_gateway.main.frontend_port[0].port == 80 && azurerm_application_gateway.main.backend_http_settings[0].port == 80
    error_message = "Listener e backend devem operar na porta 80 (TLS termina na Cloudflare, não no Application Gateway)"
  }

  assert {
    condition     = azurerm_application_gateway.main.backend_http_settings[0].cookie_based_affinity == "Disabled"
    error_message = "Afinidade de sessão deve ficar desabilitada para permitir round-robin por requisição entre os app servers"
  }

  assert {
    condition     = azurerm_public_ip.lb_ip.allocation_method == "Static"
    error_message = "IP público do Application Gateway deve ser estático"
  }
}
