# =====================================================================
# MÓDULO APP_ENVIRONMENT - OUTPUTS (CONTRATO DE INFRAESTRUTURA)
# =====================================================================

# --- Saídas para o(s) Servidor(es) de Aplicação ---

output "app_server_ids" {
  description = "Lista de IDs das instâncias de aplicação (Necessário para o Target Group do Load Balancer)."
  value       = aws_instance.app_server[*].id
}

output "app_server_private_ips" {
  description = "Lista de IPs privados das instâncias (Necessário para o inventário dinâmico do Ansible via Bastion)."
  value       = aws_instance.app_server[*].private_ip
}

# --- Saídas para o Servidor de Banco de Dados ---

output "db_server_id" {
  description = "ID da instância EC2 do servidor de banco de dados."
  value       = aws_instance.db_server.id
}

output "db_server_private_ip" {
  description = "Endereço IP privado do servidor de banco de dados."
  value       = aws_instance.db_server.private_ip
}

output "db_server_availability_zone" {
  description = "Zona de Disponibilidade do banco (Utilizado para garantir paridade no anexo de volumes)."
  value       = aws_instance.db_server.availability_zone
}