output "app_server_ids" {
  description = "Lista de IDs das VMs de aplicação."
  value       = azurerm_linux_virtual_machine.app_server[*].id
}

# --- ADIÇÃO CRÍTICA PARA O LOAD BALANCER ---
output "app_server_nic_ids" {
  description = "Lista de IDs das interfaces de rede (NICs) das VMs de aplicação."
  value       = azurerm_network_interface.app_nic[*].id
}

output "app_server_private_ips" {
  description = "Lista de IPs privados das VMs de aplicação."
  value       = azurerm_network_interface.app_nic[*].private_ip_address
}

output "db_server_id" {
  description = "O ID da VM do servidor de banco de dados."
  value       = azurerm_linux_virtual_machine.db_server.id
}

output "db_server_private_ip" {
  description = "O IP privado do servidor de banco de dados."
  value       = azurerm_network_interface.db_nic.private_ip_address
}