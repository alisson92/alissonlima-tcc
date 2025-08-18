# =====================================================================
#   MÓDULO APP_ENVIRONMENT/OUTPUTS.TF - VERSÃO CORRIGIDA PARA HA
# =====================================================================

# --- Saídas para o(s) Servidor(es) de Aplicação ---

output "app_server_ids" {
  description = "A LISTA de IDs dos servidores de aplicação."
  # <-- MUDANÇA: Nome agora está no plural "ids"
  value       = aws_instance.app_server[*].id
}

output "app_server_private_ips" {
  description = "A LISTA de IPs privados dos servidores de aplicação."
  # <-- MUDANÇA: Nome agora está no plural "ips"
  value       = aws_instance.app_server[*].private_ip
}

# --- Saídas para o Servidor de Banco de Dados ---

output "db_server_id" {
  description = "O ID da instância EC2 do servidor de banco de dados."
  # <-- ADIÇÃO: Boa prática ter a saída do ID também.
  value       = aws_instance.db_server.id
}

output "db_server_private_ip" {
  description = "O IP privado do servidor de banco de dados."
  value       = aws_instance.db_server.private_ip
}

output "db_server_availability_zone" {
  description = "A Zona de Disponibilidade onde o servidor de banco foi criado."
  value       = aws_instance.db_server.availability_zone
}