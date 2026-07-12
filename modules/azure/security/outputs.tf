output "nsg_bastion_id" {
  description = "ID do Network Security Group do Bastion Host."
  value       = azurerm_network_security_group.bastion.id
}

output "nsg_application_id" {
  description = "ID do Network Security Group unificado para a aplicação (App e DB)."
  value       = azurerm_network_security_group.application.id
}

output "nsg_appgw_id" {
  description = "ID do Network Security Group do Application Gateway."
  value       = azurerm_network_security_group.appgw.id
}