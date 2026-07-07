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

resource "azurerm_subnet_network_security_group_association" "app_a" {
  subnet_id                 = var.private_subnet_ids[0]
  network_security_group_id = azurerm_network_security_group.application.id
}

resource "azurerm_subnet_network_security_group_association" "app_b" {
  subnet_id                 = var.private_subnet_ids[1]
  network_security_group_id = azurerm_network_security_group.application.id
}