output "db_disk_id" {
  description = "O ID do Managed Disk criado para o banco de dados."
  value       = azurerm_managed_disk.db_data.id
}