# SG para o nosso futuro Bastion Host (o porteiro de acesso administrativo)
resource "aws_security_group" "bastion" {
  name        = "bastion-${var.environment}"
  description = "Permite acesso SSH para o Bastion Host"
  vpc_id      = var.vpc_id

  # Regra de Entrada: Permite SSH (porta 22) apenas do SEU IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Regra de Saída: Permite que o Bastion acesse qualquer lugar (para atualizações e conexões internas)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-bastion-${var.environment}"
  }
}

# SG para nosso futuro Application Load Balancer (o porteiro de acesso da aplicação)
resource "aws_security_group" "alb" {
  name        = "alb-${var.environment}"
  description = "Permite tráfego web para o Load Balancer"
  vpc_id      = var.vpc_id

  # Regra de Entrada: Permite HTTP e HTTPS de qualquer lugar da internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-alb-${var.environment}"
  }
}

# SG para os Servidores de Aplicação
resource "aws_security_group" "app" {
  name        = "app-${var.environment}"
  description = "Regras para os servidores de aplicação"
  vpc_id      = var.vpc_id

  # Regra de Entrada: Permite tráfego vindo APENAS do Load Balancer
  ingress {
    from_port       = 80 # Ou a porta da sua aplicação
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Regra de Entrada: Permite SSH vindo APENAS do Bastion Host
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-app-${var.environment}"
  }
}

# SG para os Servidores de Banco de Dados
resource "aws_security_group" "db" {
  name        = "db-${var.environment}"
  description = "Regras para os servidores de banco de dados"
  vpc_id      = var.vpc_id

  # Regra de Entrada: Permite tráfego na porta do banco (ex: 3306 para MySQL) vindo APENAS dos servidores de aplicação
  ingress {
    from_port       = 3306/1433
    to_port         = 3306/1433
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # Regra de Entrada: Permite SSH vindo APENAS do Bastion Host
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Servidores de DB em sub-rede privada não precisam de regra de saída para a internet por padrão.

  tags = {
    Name = "sg-db-${var.environment}"
  }
}
