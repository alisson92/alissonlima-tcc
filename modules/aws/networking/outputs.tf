output "vpc_id" {
  description = "O ID da VPC criada."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block_output" {
  description = "O bloco CIDR da VPC criada."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" { # <-- Mudou para plural
  description = "Lista de IDs das sub-redes publicas."
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" { # <-- Mudou para plural
  description = "Lista de IDs das sub-redes privadas."
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

# --- LINHA ADICIONADA/CORRIGIDA ---
output "private_subnet_availability_zone" {
  description = "A Zona de Disponibilidade da primeira sub-rede privada (AZ 'a')."
  value       = aws_subnet.private_a.availability_zone
}