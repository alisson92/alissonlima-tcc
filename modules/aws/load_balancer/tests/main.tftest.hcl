mock_provider "aws" {}

variables {
  vpc_id            = "vpc-0111111111111111a"
  public_subnet_ids = ["subnet-0222222222222222b", "subnet-0333333333333333c"]
  sg_alb_id         = "sg-0444444444444444d"
  environment       = "teste"
  app_server_ids    = ["i-0555555555555555e", "i-0666666666666666f"]
  tags              = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

run "alb_is_internet_facing_on_port_80" {
  command = plan

  assert {
    condition     = aws_lb.main.internal == false
    error_message = "ALB precisa ser internet-facing para receber tráfego da Cloudflare"
  }

  assert {
    condition     = aws_lb_listener.http.port == 80
    error_message = "Listener deve escutar na porta 80 (TLS termina na Cloudflare, não no ALB)"
  }
}

run "target_group_attachments_match_app_server_ids" {
  command = plan

  assert {
    condition     = length(aws_lb_target_group_attachment.app) == length(var.app_server_ids)
    error_message = "Número de anexos ao Target Group deve corresponder à lista de app_server_ids"
  }
}
