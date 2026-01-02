output "vpc_id" {
  description = "O ID da VPC criada."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block_output" {
  description = "O bloco CIDR da VPC criada."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Lista de IDs das sub-redes públicas."
  value       = aws_subnet.public[*].id # Captura todos os IDs da lista criada pelo count
}

output "private_subnet_ids" {
  description = "Lista de IDs das sub-redes privadas."
  value       = aws_subnet.private[*].id # Captura todos os IDs da lista criada pelo count
}

output "private_subnet_availability_zones" {
  description = "Lista das Zonas de Disponibilidade das sub-redes privadas."
  value       = aws_subnet.private[*].availability_zone
}