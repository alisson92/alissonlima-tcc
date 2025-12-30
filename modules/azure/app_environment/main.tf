# =====================================================================
#   MÓDULO APP_ENVIRONMENT/MAIN.TF - VERSÃO AZURE
# =====================================================================

# --- 1. Interfaces de Rede (NICs) para Aplicação ---
resource "azurerm_network_interface" "app_nic" {
  count               = var.app_server_count
  name                = "nic-app-${count.index}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
    private_ip_address_allocation = "Dynamic"
  }
}

# --- 2. Servidores de Aplicação (VMs) ---
resource "azurerm_linux_virtual_machine" "app_server" {
  count               = var.app_server_count
  name                = "vm-app-${count.index}-${var.environment}"
  # PADRONIZAÇÃO: Nome que aparecerá no DNS interno
  computer_name       = "app-server-${count.index}" 
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  
  # PADRONIZAÇÃO: Usuário igual ao da AWS
  admin_username      = "ubuntu" 

  network_interface_ids = [
    azurerm_network_interface.app_nic[count.index].id,
  ]

  admin_ssh_key {
    username   = "ubuntu" # Deve ser igual ao admin_username
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

# --- 3. Interface de Rede para o Banco de Dados ---
resource "azurerm_network_interface" "db_nic" {
  name                = "nic-db-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.private_subnet_ids[0]
    private_ip_address_allocation = "Dynamic"
  }
}

# --- 4. Servidor de Banco de Dados ---
resource "azurerm_linux_virtual_machine" "db_server" {
  name                = "vm-db-${var.environment}"
  # PADRONIZAÇÃO: Nome que aparecerá no DNS interno
  computer_name       = "db-server"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = "ubuntu" # PADRONIZAÇÃO
  
  network_interface_ids = [
    azurerm_network_interface.db_nic.id,
  ]

  admin_ssh_key {
    username   = "ubuntu"
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

# --- 5. Anexo de Disco de Dados (Equivalente ao EBS Attachment) ---
resource "azurerm_virtual_machine_data_disk_attachment" "db_data" {
  managed_disk_id    = var.db_disk_id
  virtual_machine_id = azurerm_linux_virtual_machine.db_server.id
  lun                = "10"
  caching            = "ReadWrite"
}

# --- 6. Registros de DNS Privado (Azure Private DNS) ---

# Registro GENÉRICO (Serviço)
resource "azurerm_private_dns_a_record" "app_service" {
  name                = "app-server"
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 60
  records             = azurerm_network_interface.app_nic[*].private_ip_address
}

# Registros INDIVIDUAIS (Admin)
resource "azurerm_private_dns_a_record" "app_admin" {
  count               = var.app_server_count
  name                = "app-server-${count.index}"
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_network_interface.app_nic[count.index].private_ip_address]
}

# Registro Banco de Dados
resource "azurerm_private_dns_a_record" "db_dns" {
  name                = "db-server"
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_network_interface.db_nic.private_ip_address]
}