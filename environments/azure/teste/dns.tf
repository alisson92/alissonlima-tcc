# =====================================================================
# DNS.TF (AZURE) - AUTOMAÇÃO DE DNS PÚBLICO VIA CLOUDFLARE
# =====================================================================

# --- 1. DNS DA APLICAÇÃO (URL DE ACESSO) ---
resource "cloudflare_record" "app_azure" {
  count   = var.create_environment ? 1 : 0
  
  zone_id = var.cloudflare_zone_id
  name    = "teste-azure" # URL: teste-azure.alissonlima.dev.br
  content = module.load_balancer[0].load_balancer_public_ip
  type    = "A"
  proxied = true
}

# --- 2. DNS DO BASTION (ACESSO ADMIN) ---
resource "cloudflare_record" "bastion_azure" {
  count   = var.create_environment ? 1 : 0

  zone_id = var.cloudflare_zone_id
  name    = "bastion-azure-teste" # URL: bastion-azure-teste.alissonlima.dev.br
  content = module.bastion_host[0].bastion_public_ip
  type    = "A"
  proxied = false # SSH deve ser 'DNS Only' (Nuvem Cinza)
}