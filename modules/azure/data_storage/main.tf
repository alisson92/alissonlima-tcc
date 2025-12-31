# =================================================================
#        CONFIGURAÇÃO DE ARMAZENAMENTO AZURE (MANAGED DISK)
# =================================================================

resource "azurerm_managed_disk" "db_data" {
  name                 = "disk-db-data-${var.environment}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS" # Custo-benefício para o TCC
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gb

  tags = merge(var.tags, {
    Name = "disk-db-data-${var.environment}"
  })
}