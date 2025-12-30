# =================================================================
#        MÓDULO BASTION HOST - AZURE (100% INDEPENDENTE)
# =================================================================

# 1. Configuração de Provedores do Módulo
# REMOVIDO: Provedor AWS para garantir independência total.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

# 2. IP Público para o Bastion Host
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 3. Interface de Rede (NIC)
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

# 4. Máquina Virtual Linux (Ubuntu Server)
resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "vm-bastion-${var.environment}"
  # PADRONIZAÇÃO: Nome que aparecerá no DNS interno/hostname
  computer_name       = "bastion" 
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  
  # PADRONIZAÇÃO: Usuário 'ubuntu' para paridade total com AWS
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

# NOTA TÉCNICA: Os registros de DNS (A Records) foram movidos 
# para o ambiente (environments/azure/teste/main.tf) para 
# evitar dependências de provedores externos dentro deste módulo.