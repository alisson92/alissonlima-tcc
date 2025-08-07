# SG para o nosso futuro Bastion Host
resource "aws_security_group" "bastion" {
  name        = "bastion-${var.environment}"
  description = "Permite acesso SSH para o Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-bastion-${var.environment}" }
}

# SG para os Servidores de Aplicação (SIMPLIFICADO PARA DEBUG)
resource "aws_security_group" "app" {
  name        = "app-${var.environment}"
  description = "Regras para os servidores de aplicacao"
  vpc_id      = var.vpc_id

  # Regra de Entrada: Permite porta 80 de QUALQUER LUGAR DENTRO DA VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Regra de Entrada: Permite SSH de QUALQUER LUGAR DENTRO DA VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-app-${var.environment}" }
}

# SG para os Servidores de Banco de Dados (SIMPLIFICADO PARA DEBUG)
resource "aws_security_group" "db" {
  name        = "db-${var.environment}"
  description = "Regras para os servidores de banco de dados"
  vpc_id      = var.vpc_id

  # Regra de Entrada: Permite porta 3306 de QUALQUER LUGAR DENTRO DA VPC
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Regra de Entrada: Permite SSH de QUALQUER LUGAR DENTRO DA VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-db-${var.environment}" }
}

# Removemos o SG do ALB temporariamente para simplificar
