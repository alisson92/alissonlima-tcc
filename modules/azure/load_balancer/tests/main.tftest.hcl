mock_provider "azurerm" {}

variables {
  resource_group_name = "rg-tcc-teste"
  location            = "East US"
  environment         = "teste"
  tags                = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

run "lb_is_standard_sku_on_port_80" {
  command = plan

  assert {
    condition     = azurerm_lb.main.sku == "Standard"
    error_message = "Load Balancer deve usar SKU Standard"
  }

  assert {
    condition     = azurerm_lb_rule.http.frontend_port == 80 && azurerm_lb_rule.http.backend_port == 80
    error_message = "Regra de LB deve balancear na porta 80 (TLS termina na Cloudflare, não no LB)"
  }

  assert {
    condition     = azurerm_public_ip.lb_ip.allocation_method == "Static"
    error_message = "IP público do Load Balancer deve ser estático"
  }
}
