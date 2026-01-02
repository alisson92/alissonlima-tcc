# =====================================================================
# DNS.TF - AUTOMAÇÃO DE DNS PÚBLICO (CLOUDFLARE) E PRIVADO (ROUTE 53)
# =====================================================================

# --- 1. DNS PÚBLICO (CLOUDFLARE) ---

resource "cloudflare_record" "app_aws" {
  # Garante que o registro só exista se o ambiente for criado
  count   = var.create_environment ? 1 : 0 
  
  zone_id = var.cloudflare_zone_id
  name    = "teste-aws"
  content = module.load_balancer[0].alb_dns_name
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "bastion_aws" {
  count   = var.create_environment ? 1 : 0

  zone_id = var.cloudflare_zone_id
  name    = "bastion-teste"
  content = module.bastion_host[0].bastion_public_ip
  type    = "A"
  proxied = false
}

# --- 2. DNS PRIVADO (ROUTE 53 - RESOLUÇÃO INTERNA DINÂMICA) ---

resource "aws_route53_zone" "internal" {
  count = var.create_environment ? 1 : 0
  
  name  = "internal.alissonlima.dev.br"
  vpc {
    vpc_id = module.networking[0].vpc_id
  }
}

resource "aws_route53_record" "db_internal" {
  count   = var.create_environment ? 1 : 0

  zone_id = aws_route53_zone.internal[0].zone_id
  name    = "db-server"
  type    = "A"
  ttl     = "300"
  records = [module.db_server[0].db_server_private_ip]
}

resource "aws_route53_record" "app_internal" {
  count   = var.create_environment ? 1 : 0

  zone_id = aws_route53_zone.internal[0].zone_id
  name    = "app-server"
  type    = "A"
  ttl     = "300"
  records = [module.app_server[0].app_server_private_ips[0]]
}