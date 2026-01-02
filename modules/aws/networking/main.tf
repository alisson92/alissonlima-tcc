# Busca as AZs disponíveis na região configurada
data "aws_availability_zones" "available" {}

# VPC Principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(var.tags, {
    Name = "vpc-tcc-${var.environment}"
  })
}

# --- SUB-REDES PÚBLICAS (Bastion e Load Balancer) ---
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index) # IPs 10.X.0.0 e 10.X.1.0
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "subnet-public-tcc-${count.index == 0 ? "a" : "b"}-${var.environment}"
  })
}

# --- SUB-REDES PRIVADAS (App e Banco de Dados) ---
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + 10) # IPs 10.X.10.0 e 10.X.11.0
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "subnet-private-tcc-${count.index == 0 ? "a" : "b"}-${var.environment}"
  })
}

# --- INTERNET GATEWAY ---
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.tags, {
    Name = "igw-tcc-${var.environment}"
  })
}

# --- ROTEAMENTO PÚBLICO ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  
  tags = merge(var.tags, {
    Name = "rt-public-tcc-${var.environment}"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- LÓGICA DO NAT GATEWAY (Saída para as Subnets Privadas) ---
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]

  tags = merge(var.tags, {
    Name = "eip-nat-tcc-${var.environment}"
  })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # NAT sempre em subnet pública

  tags = merge(var.tags, {
    Name = "nat-gw-tcc-${var.environment}"
  })
}

# --- ROTEAMENTO PRIVADO ---
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.tags, {
    Name = "rt-private-tcc-${var.environment}"
  })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}