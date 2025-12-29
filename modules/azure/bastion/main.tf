# 1. IP Público para o Bastion Host
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 2. Interface de Rede (NIC) vinculada ao IP Público
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

# 3. Máquina Virtual Linux (Equivalente ao aws_instance)
resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "vm-bastion-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s" # Ideal para o custo-benefício do TCC
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.bastion_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_key # Conteúdo da chave pública (geralmente vinda de uma variável ou arquivo)
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

# 4. Registro DNS Público (Equivalente ao Route 53)
resource "azurerm_dns_a_record" "bastion_dns" {
  name                = "bastion-${var.environment}"
  zone_name           = var.domain_name
  resource_group_name = var.resource_group_name # Assumindo que a zona DNS está no mesmo RG
  ttl                 = 300
  records             = [azurerm_public_ip.bastion_pip.ip_address]
}