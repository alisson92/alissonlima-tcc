output "nsg_bastion_id" {
  description = "ID do Network Security Group do Bastion Host."
  value       = azurerm_network_security_group.bastion.id
}

output "nsg_alb_id" {
  description = "ID do Network Security Group do Load Balancer (Azure LB)."
  value       = azurerm_network_security_group.alb.id
}

output "nsg_application_id" {
  description = "ID do Network Security Group unificado para a aplicação (App e DB)."
  value       = azurerm_network_security_group.application.id
}