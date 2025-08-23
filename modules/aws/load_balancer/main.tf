# Cria o Application Load Balancer
resource "aws_lb" "main" {
  name               = "alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "alb-${var.environment}"
  })
}

# Cria um "Target Group", que é o grupo de servidores para onde o tráfego será enviado
resource "aws_lb_target_group" "main" {
  name     = "tg-app-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    protocol = "HTTP"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1 # Duração do cookie de sessão em segundos. 1 segundo é ideal para demonstração.
    enabled         = true
  }

    tags = merge(var.tags, {
    Name = "tg-app-${var.environment}"
  })
}

# Listener para a porta 80 (HTTP) que redireciona para HTTPS
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener principal na porta 443 (HTTPS)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn # <-- Usa o certificado

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}