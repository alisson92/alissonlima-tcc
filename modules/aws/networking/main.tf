# Cria a VPC (a "caixa")
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc-${var.environment}"
  }
}

# --- PAR DE SUB-REDES NA PRIMEIRA AZ (ex: us-east-1a) ---
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 0)
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "subnet-public-a-${var.environment}"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 1)
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "subnet-private-a-${var.environment}"
  }
}

# --- PAR DE SUB-REDES NA SEGUNDA AZ (ex: us-east-1b) ---
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"
  tags = {
    Name = "subnet-public-b-${var.environment}"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 3)
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "subnet-private-b-${var.environment}"
  }
}

# --- RECURSOS DE REDE COMUNS ---
# Cria a "porta para a rua"
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "igw-${var.environment}" }
}

# Cria o "mapa de rotas" para as sub-redes públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "rt-public-${var.environment}" }
}

# Associa o mapa de rotas às DUAS sub-redes públicas
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# --- LÓGICA DO NAT GATEWAY PARA ACESSO À INTERNET DA REDE PRIVADA ---

# 1. Aloca um endereço de IP Fixo para o nosso NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  # Garante que o IP só seja criado se o Internet Gateway já existir
  depends_on = [aws_internet_gateway.gw]
}

# 2. Cria o NAT Gateway na sub-rede PÚBLICA
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id # Colocamos na primeira sub-rede pública

  tags = {
    Name = "nat-gw-${var.environment}"
  }
}

# 3. Cria um novo "mapa de rotas" para as sub-redes PRIVADAS
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0" # Para qualquer lugar da internet...
    nat_gateway_id = aws_nat_gateway.nat.id # ...use o NAT Gateway como saída.
  }

  tags = {
    Name = "rt-private-${var.environment}"
  }
}

# 4. Associa este novo mapa de rotas às DUAS sub-redes privadas
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}