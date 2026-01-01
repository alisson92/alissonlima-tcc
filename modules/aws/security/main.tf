# ==========================================
# 1. SECURITY GROUP: BASTION (O Porteiro)
# ==========================================
resource "aws_security_group" "bastion" {
  name        = "sg-tcc-bastion-${var.environment}"
  description = "Acesso administrativo via Bastion"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "sg-tcc-bastion-${var.environment}"
  })
}

# Regra para seu IP Fixo (Opcional, para seu acesso pessoal)
resource "aws_security_group_rule" "bastion_ssh_owner" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.bastion.id
}

# Saída livre para o Bastion
resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

# ==========================================
# 2. SECURITY GROUP: ALB (Load Balancer)
# ==========================================
resource "aws_security_group" "alb" {
  name        = "sg-tcc-alb-${var.environment}"
  description = "Acesso Web externo para o Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "sg-tcc-alb-${var.environment}"
  })
}

resource "aws_security_group_rule" "alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# ==========================================
# 3. SECURITY GROUP: APPLICATION (App & DB)
# ==========================================
resource "aws_security_group" "application" {
  name        = "sg-tcc-app-${var.environment}"
  description = "Regras para App e comunicacao interna de DB"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "sg-tcc-app-${var.environment}"
  })
}

# Entrada do ALB na porta 80
resource "aws_security_group_rule" "app_ingress_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.application.id
}

# Entrada do Bastion na porta 22 (SSH)
resource "aws_security_group_rule" "app_ingress_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.application.id
}

# Comunicacao interna MySQL (Self)
resource "aws_security_group_rule" "app_ingress_db_self" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.application.id
}

# Saída livre para os servidores
resource "aws_security_group_rule" "app_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.application.id
}