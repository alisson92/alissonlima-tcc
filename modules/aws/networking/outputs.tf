output "vpc_id" {
  description = "O ID da VPC criada."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "O ID da sub-rede pública."
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "O ID da sub-rede privada."
  value       = aws_subnet.private.id
}

output "vpc_cidr_block_output" {
  description = "O bloco CIDR da VPC criada."
  value       = aws_vpc.main.cidr_block
}
