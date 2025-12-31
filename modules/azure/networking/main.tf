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
resource "azurerm_public_ip" "nat" {
  name                = "pip-nat-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "main" {
  name                = "nat-gw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "private_a" {
  subnet_id      = azurerm_subnet.private_a.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_subnet_nat_gateway_association" "private_b" {
  subnet_id      = azurerm_subnet.private_b.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

# =================================================================
#        CONFIGURAÇÃO DE DNS (INTERNO E PÚBLICO)
# =================================================================

# 1. DNS PRIVADO: Isolado para cada Cloud (Padronizado .internal)
resource "azurerm_private_dns_zone" "internal" {
  name                = "internal.alissonlima.dev.br"
  resource_group_name = var.resource_group_name
}

# 2. VÍNCULO DO DNS PRIVADO: Habilita o Auto-Registro das VMs
resource "azurerm_private_dns_zone_virtual_network_link" "internal_link" {
  name                  = "vnet-dns-link-${var.environment}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.internal.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = true # VMs registrarão seus computer_names automaticamente
}

# 3. DNS PÚBLICO: Torna a Azure autoritativa para o subdomínio .azure
resource "azurerm_dns_zone" "public" {
  name                = "azure.alissonlima.dev.br"
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    Purpose = "Public Resolution for Azure Environment"
  })
}