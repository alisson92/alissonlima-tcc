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

# 2. NSG para a APLICAÇÃO (Ajustado para receber tráfego externo)
resource "azurerm_network_security_group" "application" {
  name                = "nsg-application-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # RISCO ACEITO (revisado no hardening do TCC, item #4 do HARDENING_CHECKLIST.md):
  # Esta subnet é privada, mas o tráfego web público real chega aqui vindo de fora
  # da VNet. Caminho: cliente -> Cloudflare (proxied, TLS termina lá) -> nova conexão
  # HTTP da borda da Cloudflare para o IP público do Azure LB -> o Standard LB
  # preserva o IP de origem no caminho de entrada (sem SNAT) -> este NSG enxerga o
  # IP da Cloudflare, que é externo à VNet. Por isso "VirtualNetwork" quebraria o
  # acesso público real, e "*" é usado deliberadamente. A mitigação mais forte seria
  # restringir source_address_prefixes às faixas de IP publicadas pela Cloudflare
  # (cloudflare.com/ips), mas isso foi conscientemente adiado para não introduzir a
  # dependência de manter essa lista atualizada — hoje a Cloudflare + WAF já filtra
  # boa parte do tráfego malicioso antes de chegar ao origin.
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

  # Regra "AllowAzureLoadBalancerProbe" (source AzureLoadBalancer) removida:
  # o tráfego e o health probe agora chegam do Application Gateway, que roda
  # dentro da VNet (subnet dedicada), não mais via serviço gerenciado externo
  # com o service tag AzureLoadBalancer. Já é coberto pela regra AllowHTTPInbound
  # acima (porta 80, source "*").

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

# 3. NSG para o Application Gateway (regras obrigatórias da Microsoft para v2)
resource "azurerm_network_security_group" "appgw" {
  name                = "nsg-appgw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # OBRIGATÓRIA: canal de gerenciamento do control plane do Application
  # Gateway v2. Sem isso o provisionamento do recurso falha.
  security_rule {
    name                       = "AllowGatewayManagerInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  # Tráfego público do listener HTTP (porta 80), vindo do Cloudflare.
  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Infra de health check da Azure.
  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# --- ASSOCIAÇÕES ---

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = var.public_subnet_ids[0]
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_subnet_network_security_group_association" "app_a" {
  subnet_id                 = var.private_subnet_ids[0]
  network_security_group_id = azurerm_network_security_group.application.id
}

resource "azurerm_subnet_network_security_group_association" "app_b" {
  subnet_id                 = var.private_subnet_ids[1]
  network_security_group_id = azurerm_network_security_group.application.id
}

resource "azurerm_subnet_network_security_group_association" "appgw" {
  subnet_id                 = var.appgw_subnet_id
  network_security_group_id = azurerm_network_security_group.appgw.id
}