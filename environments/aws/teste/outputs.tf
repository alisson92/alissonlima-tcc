# Exibe o IP público do Bastion Host para facilitar a conexão SSH
output "bastion_public_ip" {
  description = "IP Público do Bastion Host para acesso SSH."
  value       = var.create_environment ? module.bastion_host[0].bastion_public_ip : "N/A (ambiente destruído)"
}

# Exibe os IPs privados dos servidores para facilitar os testes de conexão interna
output "app_server_private_ip" {
  description = "IP Privado do servidor de aplicação."
  value       = var.create_environment ? module.app_environment[0].app_server_private_ip : "N/A (ambiente destruído)"
}

output "db_server_private_ip" {
  description = "IP Privado do servidor de banco de dados."
  value       = var.create_environment ? module.app_environment[0].db_server_private_ip : "N/A (ambiente destruído)"
}

# --- LINHA ADICIONADA/CORRIGIDA ---
# Exporta o ID do Security Group do Bastion para o pipeline
output "sg_bastion_id" {
  description = "ID do Security Group do Bastion Host."
  value       = var.create_environment ? module.security[0].sg_bastion_id : "N/A (ambiente destruído)"
}