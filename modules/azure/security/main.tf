# =================================================================
#        CONFIGURAÇÃO DE SEGURANÇA AZURE (NSG)
# =================================================================

# 1. NSG para o Bastion Host (Equivalente ao SG do Bastion)
resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-bastion-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Regra de Entrada: Permite SSH (porta 22) apenas do SEU IP
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

  tags = merge(var.tags, {
    Name = "nsg-bastion-${var.environment}"
  })
}

# 2. NSG para o Application Load Balancer (Equivalente ao SG do ALB)
resource "azurerm_network_security_group" "alb" {
  name                = "nsg-alb-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Regra de Entrada: Permite HTTP (80) de qualquer lugar
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

  # Regra de Entrada: Permite HTTPS (443) de qualquer lugar
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

  tags = merge(var.tags, {
    Name = "nsg-alb-${var.environment}"
  })
}

# 3. NSG ÚNICO para a APLICAÇÃO (App e DB)
resource "azurerm_network_security_group" "application" {
  name                = "nsg-application-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Regra 1: Permite tráfego HTTP vindo da VNet (Simula o acesso do ALB)
  security_rule {
    name                       = "AllowHTTPFromVNet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Regra 2: Permite tráfego SSH vindo do Bastion (Interno)
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

  # Regra 3: Permite MySQL interno (Simula o self=true do AWS)
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

  tags = merge(var.tags, {
    Name = "nsg-application-${var.environment}"
  })
}

# --- ASSOCIAÇÕES DE SEGURANÇA ---

# 1. Associa o NSG do Bastion à Subnet Pública A
resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = var.public_subnet_ids[0]
  network_security_group_id = azurerm_network_security_group.bastion.id
}

# 2. Associa o NSG de Aplicação às Subnets Privadas (Onde ficarão App e DB)
resource "azurerm_subnet_network_security_group_association" "app_a" {
  subnet_id                 = var.private_subnet_ids[0]
  network_security_group_id = azurerm_network_security_group.application.id
}

resource "azurerm_subnet_network_security_group_association" "app_b" {
  subnet_id                 = var.private_subnet_ids[1]
  network_security_group_id = azurerm_network_security_group.application.id
}