# =================================================================
#        CONFIGURAÇÃO DE REDE AZURE (VIRTUAL NETWORK)
# =================================================================

# 1. Cria a VNet (Equivalente à VPC da AWS)
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  address_space       = [var.vnet_cidr_block]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    Name = "vnet-${var.environment}"
  })
}

# --- DEFINIÇÃO DAS SUB-REDES ---
# No Azure, as subnets são declaradas dentro da VNet ou como recursos separados.
# Usaremos recursos separados para manter a paridade com seu código AWS.

resource "azurerm_subnet" "public_a" {
  name                 = "subnet-public-a-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr_block, 8, 0)]
}

resource "azurerm_subnet" "private_a" {
  name                 = "subnet-private-a-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr_block, 8, 1)]
}

resource "azurerm_subnet" "public_b" {
  name                 = "subnet-public-b-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr_block, 8, 2)]
}

resource "azurerm_subnet" "private_b" {
  name                 = "subnet-private-b-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr_block, 8, 3)]
}

# --- LÓGICA DE SAÍDA PARA INTERNET (NAT GATEWAY) ---
# No Azure, a saída para internet em subnets públicas é automática.
# Para as subnets PRIVADAS, usamos o Azure NAT Gateway (equivalente ao NAT GW da AWS).

# 1. IP Público para o NAT Gateway
resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 2. O recurso NAT Gateway
resource "azurerm_nat_gateway" "main" {
  name                = "nat-gw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
}

# 3. Associa o IP ao NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# 4. Associa o NAT Gateway às Subnets PRIVADAS (Garante saída segura)
resource "azurerm_subnet_nat_gateway_association" "private_a" {
  subnet_id      = azurerm_subnet.private_a.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_subnet_nat_gateway_association" "private_b" {
  subnet_id      = azurerm_subnet.private_b.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}
