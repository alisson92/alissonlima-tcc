output "bastion_public_ip" {
  description = "IP público do Bastion Host"
  # Adicionado [0] antes do atributo
  value       = module.bastion_host[0].bastion_public_ip
}

output "lb_public_ip" {
  description = "IP público do Load Balancer"
  # Adicionado [0] antes do atributo
  value       = module.load_balancer[0].lb_public_ip
}

output "app_server_private_ips" {
  description = "Lista de IPs privados das VMs de aplicação"
  # Adicionado [0] antes do atributo
  value       = module.app_environment[0].app_server_private_ips
}

output "db_server_private_ip" {
  description = "IP privado do banco de dados"
  # Adicionado [0] antes do atributo
  value       = module.app_environment[0].db_server_private_ip
}