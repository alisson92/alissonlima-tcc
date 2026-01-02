# =====================================================================
# ENVIRONMENTS/TESTE/DNS.TF - AUTOMAÇÃO DE APONTAMENTOS CLOUDFLARE
# =====================================================================

# 1. Registro do Site (teste-aws.alissonlima.dev.br)
resource "cloudflare_record" "app_aws" {
  zone_id = var.cloudflare_zone_id
  name    = "teste-aws"
  content   = module.load_balancer[0].alb_dns_name # Pega dinamicamente do ALB
  type    = "CNAME"
  proxied = true # Nuvem Laranja (SSL + Proteção)
}

# 2. Registro do Bastion (bastion-teste.alissonlima.dev.br)
resource "cloudflare_record" "bastion_aws" {
  zone_id = var.cloudflare_zone_id
  name    = "bastion-teste"
  content   = module.bastion_host[0].bastion_public_ip # Pega dinamicamente o IP
  type    = "A"
  proxied = false # Nuvem Cinza (Obrigatório para SSH funcionar no PuTTY)
}