# --- OUTPUTS DINÂMICOS E RESILIENTES (TCC AZURE) ---

output "bastion_public_ip" {
  description = "IP público do Bastion Host"
  # O [*] extrai o atributo de todos os itens da lista (mesmo que seja zero)
  # O one() retorna o valor se a lista tiver 1 item, ou null se estiver vazia
  value       = one(module.bastion_host[*].bastion_public_ip)
}

output "lb_public_ip" {
  description = "IP público do Load Balancer"
  value       = one(module.load_balancer[*].lb_public_ip)
}

output "app_server_private_ips" {
  description = "Lista de IPs privados das VMs de aplicação"
  value       = one(module.app_environment[*].app_server_private_ips)
}

output "db_server_private_ip" {
  description = "IP privado do banco de dados"
  value       = one(module.app_environment[*].db_server_private_ip)
}