# Cria o Application Load Balancer
resource "aws_lb" "main" {
  name               = "alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "alb-${var.environment}"
  }
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
}

# Cria um "Listener" na porta 80 (HTTP)
# Ele "escuta" o tráfego e o encaminha para o Target Group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}