output "vpc_cidr_block_output" {
  description = "O bloco CIDR da VPC criada."
  value       = aws_vpc.main.cidr_block
}
