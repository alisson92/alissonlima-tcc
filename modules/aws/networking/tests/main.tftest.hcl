mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b"]
    }
  }
}

variables {
  vpc_cidr_block = "10.50.0.0/16"
  environment    = "teste"
  tags           = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

run "vpc_cidr_matches_input" {
  command = plan

  assert {
    condition     = aws_vpc.main.cidr_block == var.vpc_cidr_block
    error_message = "VPC CIDR não corresponde à variável de entrada"
  }
}

run "public_subnets_have_public_ip_on_launch" {
  command = plan

  assert {
    condition     = alltrue([for s in aws_subnet.public : s.map_public_ip_on_launch])
    error_message = "Sub-redes públicas devem atribuir IP público automaticamente"
  }
}

run "private_subnets_route_through_nat" {
  command = apply

  assert {
    condition     = alltrue([for r in aws_route_table.private.route : r.nat_gateway_id != "" && r.gateway_id == null])
    error_message = "Rota privada deve sair via NAT Gateway, não diretamente pela Internet Gateway"
  }
}
