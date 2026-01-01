# =====================================================================
# MÓDULO LOAD BALANCER - CONFIGURAÇÃO SIMPLIFICADA (BORDA NA CLOUDFLARE)
# =====================================================================

# 1. Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name               = "alb-tcc-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "alb-tcc-${var.environment}"
  })
}

# 2. Target Group (Grupo de Destino das Instâncias)
resource "aws_lb_target_group" "main" {
  name     = "tg-tcc-app-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = merge(var.tags, {
    Name = "tg-tcc-app-${var.environment}"
  })
}

# 3. Listener Simplificado (Porta 80)
# Como a Cloudflare gerencia o SSL (HTTPS) e o redirecionamento, 
# o ALB recebe o tráfego tratado via HTTP.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# 4. Anexo das Instâncias de Aplicação ao Target Group
# Este recurso garante que as instâncias criadas no módulo app_environment 
# sejam registradas no Load Balancer.
resource "aws_lb_target_group_attachment" "app" {
  count            = length(var.app_server_ids)
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.app_server_ids[count.index]
  port             = 80
}