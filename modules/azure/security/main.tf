# =================================================================
#        CONFIGURAÇÃO DE SEGURANÇA AZURE (CORRIGIDA)
# =================================================================

# 1. NSG para o Bastion Host
resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-bastion-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowSSHInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# 2. NSG para o Load Balancer (Abertura para a Internet/Cloudflare)
resource "azurerm_network_security_group" "alb" {
  name                = "nsg-alb-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*" # Permite que a Cloudflare/Internet chegue ao LB
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# 3. NSG para a APLICAÇÃO (Ajustado para receber tráfego externo)
resource "azurerm_network_security_group" "application" {
  name                = "nsg-application-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # AJUSTE: Permite tráfego HTTP de qualquer origem (necessário pois o LB preserva o IP)
  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*" 
    destination_address_prefix = "*"
  }

  # NOVO: Permite o Health Probe do Azure Load Balancer
  # Sem isso, o LB acha que a VM está fora do ar e não envia tráfego.
  security_rule {
    name                       = "AllowAzureLoadBalancerProbe"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSHFromBastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowMySQLInternal"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# --- ASSOCIAÇÕES ---

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = var.public_subnet_ids[0]
  network_security_group_id = azurerm_network_security_group.bastion.id
}

# ASSOCIAÇÃO DO ALB (Faltava no seu código)
# Importante: Se o seu LB estiver na mesma subnet do Bastion, 
# você precisará unificar as regras em um único NSG.
# Assumindo que você tem uma subnet dedicada ao LB ou quer proteger a pública:
# resource "azurerm_subnet_network_security_group_association" "alb" {
#   subnet_id                 = var.public_subnet_ids[1] # Use a subnet correta aqui
#   network_security_group_id = azurerm_network_security_group.alb.id
# }

resource "azurerm_subnet_network_security_group_association" "app_a" {
  subnet_id                 = var.private_subnet_ids[0]
  network_security_group_id = azurerm_network_security_group.application.id
}

resource "azurerm_subnet_network_security_group_association" "app_b" {
  subnet_id                 = var.private_subnet_ids[1]
  network_security_group_id = azurerm_network_security_group.application.id
}