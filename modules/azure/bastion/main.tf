# --- CONFIGURAÇÃO DE PROVEDORES DO MÓDULO ---
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1. IP Público para o Bastion Host
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 2. Interface de Rede (NIC)
resource "azurerm_network_interface" "bastion_nic" {
  name                = "nic-bastion-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "external"
    subnet_id                     = var.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }
}

# 3. Máquina Virtual Linux
resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "vm-bastion-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.bastion_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.tags
}

# --- SOLUÇÃO DE DNS MULTICLOUD (AWS ROUTE 53) ---

# 4. Busca a Zona que você já criou manualmente na AWS (conforme seu setup/dns/main.tf)
data "aws_route53_zone" "selected" {
  name         = "${var.domain_name}." # Note o ponto final para busca de FQDN
  private_zone = false
}

# 5. Registro DNS criado na AWS apontando para o IP Público da Azure
resource "aws_route53_record" "bastion_dns" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "bastion-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [azurerm_public_ip.bastion_pip.ip_address]
}