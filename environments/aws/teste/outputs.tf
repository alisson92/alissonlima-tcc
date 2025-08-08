# Exibe o IP público do Bastion Host para facilitar a conexão SSH
output "bastion_public_ip" {
  description = "IP Público do Bastion Host para acesso SSH."
  # Adiciona o [0] para acessar o primeiro (e único) item da lista do módulo
  value       = module.bastion_host_teste[0].bastion_public_ip
}

# Exibe os IPs privados dos servidores para facilitar os testes de conexão interna
output "app_server_private_ip" {
  description = "IP Privado do servidor de aplicação."
  value       = module.app_environment_teste[0].app_server_private_ip
}

output "db_server_private_ip" {
  description = "IP Privado do servidor de banco de dados."
  value       = module.app_environment_teste[0].db_server_private_ip
}
