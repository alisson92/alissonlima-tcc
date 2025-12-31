# =================================================================
#        CONFIGURAÇÃO DO LOAD BALANCER AZURE
# =================================================================

# 1. IP Público para o Load Balancer
# Ajustado de "lb_pip" para "lb_ip" para bater com o outputs.tf
resource "azurerm_public_ip" "lb_ip" {
  name                = "pip-lb-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 2. O Recurso do Load Balancer (Standard)
resource "azurerm_lb" "main" {
  name                = "lb-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
}

# 3. Backend Pool (Ajustado de "main" para "app_pool")
resource "azurerm_lb_backend_address_pool" "app_pool" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "tg-app-${var.environment}"
}

# 4. Health Probe
resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "hp-http-check"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}

# 5. Regra de Load Balancing (Ajustada para o novo nome do app_pool)
resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "LBRuleHTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_pool.id]
  probe_id                       = azurerm_lb_probe.http.id
}