output "bastion_public_ip" {
  description = "O IP público do Bastion Host para acesso administrativo."
  value       = azurerm_public_ip.bastion_pip.ip_address
}

output "bastion_id" {
  description = "ID da VM do Bastion."
  value       = azurerm_linux_virtual_machine.bastion.id
}