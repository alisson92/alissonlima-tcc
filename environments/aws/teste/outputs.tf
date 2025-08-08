# Exibe o IP público do Bastion Host para facilitar a conexão SSH
output "bastion_public_ip" {
  description = "IP Público do Bastion Host para acesso SSH."
  # Lógica condicional: se o ambiente foi criado, mostra o IP. Senão, mostra "N/A".
  value       = var.create_environment ? module.bastion_host_teste[0].bastion_public_ip : "N/A"
}

# Exibe os IPs privados dos servidores para facilitar os testes de conexão interna
output "app_server_private_ip" {
  description = "IP Privado do servidor de aplicação."
  value       = var.create_environment ? module.app_environment_teste[0].app_server_private_ip : "N/A"
}

output "db_server_private_ip" {
  description = "IP Privado do servidor de banco de dados."
  value       = var.create_environment ? module.app_environment_teste[0].db_server_private_ip : "N/A"
}
