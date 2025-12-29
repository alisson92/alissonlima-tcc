# 1. IP Público para o Load Balancer
resource "azurerm_public_ip" "lb_pip" {
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
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

# 3. Backend Pool (Equivalente ao Target Group)
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "tg-app-${var.environment}"
}

# 4. Health Probe (Equivalente ao health_check do Target Group)
resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "hp-http-check"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}

# 5. Regra de Load Balancing (Equivalente ao Listener porta 80)
resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "LBRuleHTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.http.id
}