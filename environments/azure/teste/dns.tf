# =====================================================================
# DNS.TF (AZURE) - CONSOLIDAÇÃO DE NOMES PÚBLICOS E PRIVADOS
# =====================================================================

# --- 1. DNS PÚBLICO (CLOUDFLARE) ---

resource "cloudflare_record" "app_azure" {
  count   = var.create_environment ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "${var.lb_dns_name}-azure"
  content = module.load_balancer[0].lb_public_ip
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "bastion_azure" {
  count   = var.create_environment ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "bastion-azure-teste"
  content = module.bastion_host[0].bastion_public_ip
  type    = "A"
  proxied = false
}

# --- 2. DNS PRIVADO (AZURE PRIVATE DNS - RESOLUÇÃO INTERNA) ---

resource "azurerm_private_dns_a_record" "app_internal" {
  count               = var.create_environment ? var.app_server_count : 0
  # Lógica refinada: se houver só 1, nome simples. Se houver mais, nome indexado.
  name                = var.app_server_count > 1 ? "app-server-${count.index}" : "app-server"
  zone_name           = module.networking[0].private_dns_zone_name
  resource_group_name = azurerm_resource_group.main[0].name
  ttl                 = 300
  records             = [module.app_environment[0].app_server_private_ips[count.index]]
}

resource "azurerm_private_dns_a_record" "db_internal" {
  count               = var.create_environment ? 1 : 0
  name                = "db-server"
  zone_name           = module.networking[0].private_dns_zone_name
  resource_group_name = azurerm_resource_group.main[0].name
  ttl                 = 300
  records             = [module.app_environment[0].db_server_private_ip]
}