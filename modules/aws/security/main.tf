# SG para o nosso futuro Bastion Host (o porteiro de acesso administrativo)
resource "aws_security_group" "bastion" {
  name        = "sg-bastion-${var.environment}"
  description = "Permite acesso SSH para o Bastion Host"
  vpc_id      = var.vpc_id

  # Regra de Entrada: Permite SSH (porta 22) apenas do SEU IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Regra de Saida: Permite que o Bastion acesse qualquer lugar
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "sg-bastion-${var.environment}"
  })
}

# SG para nosso futuro Application Load Balancer (o porteiro de acesso da aplicacao)
resource "aws_security_group" "alb" {
  name        = "sg-alb-${var.environment}"
  description = "Permite trafego web para o Load Balancer"
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

  # Regra de Saida: Permite que o ALB fale com qualquer lugar (para os servidores da aplicacao)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "sg-alb-${var.environment}"
  })
}

# SG ÚNICO para a APLICACAO (agrupando App e DB)
resource "aws_security_group" "application" {
  name        = "sg-application-${var.environment}"
  description = "Regras para os servidores da aplicacao (App e DB)"
  vpc_id      = var.vpc_id

  # Regra de Entrada 1: Permite trafego do Load Balancer na porta 80
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  # Regra de Entrada 2: Permite trafego do Bastion na porta 22 (SSH)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Regra de Entrada 3 (A Mágica): Permite que membros deste mesmo grupo se comuniquem na porta do banco
  ingress {
    from_port   = 3306 # Porta do MySQL
    to_port     = 3306
    protocol    = "tcp"
    self        = true # "self = true" é a chave para a comunicação interna
  }

  # Regra de Saida: Permite que os servidores acessem qualquer lugar (ex: para atualizações de pacotes)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "sg-application-${var.environment}"
  })
}
