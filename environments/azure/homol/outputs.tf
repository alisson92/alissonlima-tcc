# =====================================================================
#   ENVIRONMENTS/HOMOL/OUTPUTS.TF - VERSÃO CORRIGIDA E CONSISTENTE
# =====================================================================

output "bastion_public_ip" {
  description = "IP Público do Bastion Host para acesso SSH."
  value       = var.create_environment ? module.bastion_host[0].bastion_public_ip : "N/A (ambiente destruído)"
}

# <-- MUDANÇA: Nome e referência atualizados para a lista de IPs
output "app_server_private_ips" {
  description = "A LISTA de IPs privados dos servidores de aplicação."
  value       = var.create_environment ? module.app_environment[0].app_server_private_ips : []
}

output "db_server_private_ip" {
  description = "IP Privado do servidor de banco de dados."
  value       = var.create_environment ? module.app_environment[0].db_server_private_ip : "N/A (ambiente destruído)"
}

output "sg_bastion_id" {
  description = "ID do Security Group do Bastion Host."
  value       = var.create_environment ? module.security[0].sg_bastion_id : "N/A (ambiente destruído)"
}

output "alb_dns_name_output" {
  description = "Endereço DNS do Application Load Balancer."
  value       = var.create_environment ? "https://${var.alb_dns_name}.${data.aws_route53_zone.primary.name}" : "N/A (ambiente destruído)"
}