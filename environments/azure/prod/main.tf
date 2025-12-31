# =====================================================================
#   ENVIRONMENTS/AZURE/PROD/MAIN.TF - VERSÃO MULTICLOUD PADRONIZADA
# =====================================================================

# --- CAMADA 0: RESOURCE GROUP ---
resource "azurerm_resource_group" "main" {
  count    = var.create_environment ? 1 : 0
  name     = "rg-tcc-${var.environment_name}"
  location = var.location
  tags     = var.tags
}

# --- CAMADA 1: REDE (Agora com as Zonas DNS Internas e Públicas) ---
module "networking" {
  count               = var.create_environment ? 1 : 0
  source              = "../../../modules/azure/networking"
  resource_group_name = azurerm_resource_group.main[0].name
  location            = azurerm_resource_group.main[0].location
  environment         = var.environment_name
  vnet_cidr_block     = var.vnet_cidr_block
  tags                = var.tags
}

# --- CAMADA 2: SEGURANÇA ---
module "security" {
  count               = var.create_environment ? 1 : 0
  source              = "../../../modules/azure/security"
  resource_group_name = azurerm_resource_group.main[0].name
  location            = azurerm_resource_group.main[0].location
  environment         = var.environment_name
  vnet_cidr_block     = var.vnet_cidr_block
  my_ip               = var.my_ip
  public_subnet_ids   = module.networking[0].public_subnet_ids
  private_subnet_ids  = module.networking[0].private_subnet_ids
  tags                = var.tags
}

# --- CAMADA 2.6: CONEXÕES EXTERNAS (CLOUDFLARE DNS) ---

resource "cloudflare_record" "azure_site" {
  count   = var.create_environment ? 1 : 0 
  zone_id = var.cloudflare_zone_id
  name    = "${var.environment_name}-azure" 
  
  # CORREÇÃO: 'value' alterado para 'content' para evitar o Warning
  content = one(module.load_balancer[*].lb_public_ip) 
  
  type    = "A"
  proxied = true 
  ttl     = 1 
}

resource "cloudflare_record" "bastion_dns" {
  count   = var.create_environment ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "bastion-${var.environment_name}" 
  
  # CORREÇÃO: 'value' alterado para 'content'
  content = one(module.bastion_host[*].bastion_public_ip)
  
  type    = "A"
  proxied = false 
  ttl     = 1
}

# --- REGISTROS INTERNOS (Private DNS) ---

resource "azurerm_private_dns_a_record" "app_internal" {
  count               = var.create_environment ? var.app_server_count : 0
  # Se existir mais de um servidor, ele cria app-server-0, app-server-1...
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

# --- CAMADA 3: ARMAZENAMENTO PERSISTENTE ---
module "data_storage" {
  count               = var.create_environment ? 1 : 0
  source              = "../../../modules/azure/data_storage"
  resource_group_name = azurerm_resource_group.main[0].name
  location            = azurerm_resource_group.main[0].location
  environment         = var.environment_name
  tags                = var.tags
}

# --- CAMADA 4: COMPUTAÇÃO (Servidores) ---
module "app_environment" {
  count                 = var.create_environment ? 1 : 0
  source                = "../../../modules/azure/app_environment"
  resource_group_name   = azurerm_resource_group.main[0].name
  location              = azurerm_resource_group.main[0].location
  environment           = var.environment_name
  private_subnet_ids    = module.networking[0].private_subnet_ids
  vm_size               = var.instance_type
  # PADRONIZAÇÃO: Mudando para ubuntu para espelhar a AWS
  admin_username        = "ubuntu" 
  public_key            = var.public_key
  db_disk_id            = module.data_storage[0].db_disk_id
  private_dns_zone_name = module.networking[0].private_dns_zone_name
  app_server_count      = var.app_server_count
  tags                  = var.tags
}

# --- CAMADA 5: PONTO DE ACESSO (BASTION) ---
module "bastion_host" {
  count               = var.create_environment ? 1 : 0
  source              = "../../../modules/azure/bastion"
  resource_group_name = azurerm_resource_group.main[0].name
  location            = azurerm_resource_group.main[0].location
  public_subnet_id    = module.networking[0].public_subnet_ids[0]
  # PADRONIZAÇÃO: Usuário ubuntu para paridade com AWS
  admin_username      = "ubuntu" 
  public_key          = var.public_key
  # A LINHA 'domain_name' FOI REMOVIDA DAQUI
  environment         = var.environment_name
  tags                = var.tags
}

# --- CAMADA 6: PONTO DE ENTRADA DA APLICAÇÃO (Load Balancer) ---
module "load_balancer" {
  count               = var.create_environment ? 1 : 0
  source              = "../../../modules/azure/load_balancer"
  resource_group_name = azurerm_resource_group.main[0].name
  location            = azurerm_resource_group.main[0].location
  environment         = var.environment_name
  tags                = var.tags
}

# --- CAMADA 7: CONEXÕES FINAIS ---
resource "azurerm_network_interface_backend_address_pool_association" "app_pool_assoc" {
  count                   = var.create_environment ? var.app_server_count : 0
  network_interface_id    = module.app_environment[0].app_server_nic_ids[count.index]
  ip_configuration_name   = "internal"
  backend_address_pool_id = module.load_balancer[0].backend_pool_id
}

moved {
  from = module.data_storage
  to   = module.data_storage[0]
}