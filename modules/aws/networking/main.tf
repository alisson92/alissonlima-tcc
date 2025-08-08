# Cria a VPC (a "caixa")
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc-${var.environment}"
  }
}

# Cria a Sub-rede Pública
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 0)
  map_public_ip_on_launch = true # Instâncias aqui recebem IP público
  availability_zone       = "${var.aws_region}a" # Exemplo: us-east-1a
  tags = {
    Name = "subnet-public-${var.environment}"
  }
}

# Cria a Sub-rede Privada
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 1)
  availability_zone       = "${var.aws_region}b" # Exemplo: us-east-1b
  tags = {
    Name = "subnet-private-${var.environment}"
  }
}

# Cria a "porta para a rua"
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw-${var.environment}"
  }
}

# Cria o "mapa de rotas" para a sub-rede pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Para qualquer lugar da internet...
    gateway_id = aws_internet_gateway.gw.id # ...use a "porta para a rua".
  }

  tags = {
    Name = "rt-public-${var.environment}"
  }
}

# Associa o mapa de rotas à sub-rede pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}