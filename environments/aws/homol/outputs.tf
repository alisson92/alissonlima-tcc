# =====================================================================
# ENVIRONMENTS/HOMOL/OUTPUTS.TF - ENTREGA DE INFRAESTRUTURA
# =====================================================================

output "bastion_public_ip" {
  description = "IP Público do Bastion Host (Use para o ProxyCommand do Ansible)."
  value       = var.create_environment ? module.bastion_host[0].bastion_public_ip : "N/A"
}

output "app_server_private_ips" {
  description = "Lista de IPs privados dos servidores de aplicação para o inventário dinâmico."
  value       = var.create_environment ? module.app_environment[0].app_server_private_ips : []
}

output "db_server_private_ip" {
  description = "IP Privado do servidor de banco de dado."
  value       = var.create_environment ? module.app_environment[0].db_server_private_ip : "N/A"
}

output "sg_bastion_id" {
  description = "ID do Security Group do Bastion (Necessário para abertura dinâmica de porta 22 via CLI)."
  value       = var.create_environment ? module.security[0].sg_bastion_id : "N/A"
}

output "alb_dns_name" {
  description = "DNS gerado pela AWS para o Load Balancer. Cadastre este valor como CNAME na Cloudflare."
  value       = var.create_environment ? module.load_balancer[0].alb_dns_name : "N/A"
}