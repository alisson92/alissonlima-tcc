# =================================================================
#   CONFIGURAÇÃO DO LOAD BALANCER AZURE (APPLICATION GATEWAY - L7)
# =================================================================
#
# Migrado de Standard Load Balancer (L4) para Application Gateway (L7) para
# alcançar paridade de comportamento com o ALB da AWS: o roteamento passa a
# ser decidido por requisição HTTP, não por hash de 5-tupla fixado por
# conexão TCP — isso é o que torna a alternância entre app-server-0 e
# app-server-1 visível em refreshes sucessivos no navegador.

# 1. IP Público para o Application Gateway
resource "azurerm_public_ip" "lb_ip" {
  name                = "pip-appgw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  appgw_name                     = "appgw-${var.environment}"
  gateway_ip_configuration_name  = "gw-ip-config"
  frontend_port_name             = "frontend-port-http"
  frontend_ip_configuration_name = "frontend-ip-public"
  backend_address_pool_name      = "tg-app-${var.environment}"
  backend_http_settings_name     = "http-settings"
  http_listener_name             = "http-listener"
  probe_name                     = "hp-http-check"
  request_routing_rule_name      = "http-routing-rule"
}

# 2. Application Gateway (Standard_v2, capacidade fixa para minimizar custo —
# ambiente só sobe sob demanda para demonstração, sem necessidade de autoscale).
resource "azurerm_application_gateway" "main" {
  name                = local.appgw_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = var.backend_ip_addresses
  }

  probe {
    name                = local.probe_name
    protocol            = "Http"
    path                = "/"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  # cookie_based_affinity = "Disabled" é o que garante que cada requisição
  # HTTP seja roteada independentemente entre os backends (sem "grudar" no
  # mesmo app server por sessão), equivalente ao comportamento padrão do ALB.
  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    probe_name            = local.probe_name
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }

  tags = var.tags
}
