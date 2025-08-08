output "app_server_private_ip" {
  description = "O IP privado do servidor de aplicação."
  value       = aws_instance.app_server.private_ip
}

output "db_server_private_ip" {
  description = "O IP privado do servidor de banco de dados."
  value       = aws_instance.db_server.private_ip
}
