output "app_server_id" {
  description = "O ID da instância EC2 do servidor de aplicação."
  value       = aws_instance.app_server.id
}

output "db_server_availability_zone" {
  description = "A Zona de Disponibilidade onde o servidor de banco foi criado."
  value       = aws_instance.db_server.availability_zone
}

output "app_server_private_ip" {
  description = "O IP privado do servidor de aplicação."
  value       = aws_instance.app_server.private_ip
}

output "db_server_private_ip" {
  description = "O IP privado do servidor de banco de dados."
  value       = aws_instance.db_server.private_ip
}