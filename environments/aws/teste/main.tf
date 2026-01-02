# =====================================================================
# ENVIRONMENTS/TESTE/MAIN.TF - ORQUESTRAÇÃO FINAL (PADRÃO 2026)
# =====================================================================

# --- CAMADA 1: REDE ---
module "networking" {
  count          = var.create_environment ? 1 : 0
  source         = "../../../modules/aws/networking"
  vpc_cidr_block = var.vpc_cidr_block
  environment    = var.environment_name
  tags           = var.tags
  # aws_region removido: o módulo agora usa data source dinâmico
}

# --- CAMADA 2: SEGURANÇA ---
module "security" {
  count       = var.create_environment ? 1 : 0
  source      = "../../../modules/aws/security"
  vpc_id      = module.networking[0].vpc_id
  environment = var.environment_name
  my_ip       = var.my_ip
  tags        = var.tags
  # vpc_cidr_block removido: módulo agora usa referências entre SGs e Self
}

# --- CAMADA 3: ARMAZENAMENTO PERSISTENTE ---
module "data_storage" {
  count        = var.create_environment ? 1 : 0
  source       = "../../../modules/aws/data_storage"
  environment  = var.environment_name
  # az: Busca dinamicamente do output da rede (us-east-1a)
  az           = var.create_environment ? module.networking[0].private_subnet_availability_zones[0] : "us-east-1a"
  volume_size  = 10
  tags         = var.tags
}

# --- CAMADA 4: COMPUTAÇÃO (Servidores) ---
module "app_environment" {
  count              = var.create_environment ? 1 : 0
  source             = "../../../modules/aws/app_environment"
  private_subnet_ids = module.networking[0].private_subnet_ids
  environment        = var.environment_name
  instance_type      = var.instance_type
  sg_application_id  = module.security[0].sg_application_id
  db_volume_id       = module.data_storage[0].volume_id
  ami_id             = "ami-0a7d80731ae1b2435" # Ubuntu 22.04 LTS
  key_name           = "tcc-alisson-key"
  tags               = var.tags
  
  # AZ sincronizada com o volume para permitir o attachment
  db_server_availability_zone = var.create_environment ? module.networking[0].private_subnet_availability_zones[0] : "us-east-1a"
  
  # DNS Privado removido: Módulo agora é "puro"
}

# --- CAMADA 5: PONTO DE ACESSO (BASTION) ---
module "bastion_host" {
  count            = var.create_environment ? 1 : 0
  source           = "../../../modules/aws/bastion"
  public_subnet_id = module.networking[0].public_subnet_ids[0]
  sg_bastion_id    = module.security[0].sg_bastion_id
  environment      = var.environment_name
  ami_id           = "ami-0a7d80731ae1b2435"
  key_name         = "tcc-alisson-key"
  tags             = var.tags
  # zone_id e domain_name removidos: DNS será via Cloudflare
}

# --- CAMADA 6: PONTO DE ENTRADA DA APLICAÇÃO (ALB) ---
module "load_balancer" {
  count             = var.create_environment ? 1 : 0
  source            = "../../../modules/aws/load_balancer"
  vpc_id            = module.networking[0].vpc_id
  public_subnet_ids = module.networking[0].public_subnet_ids
  sg_alb_id         = module.security[0].sg_alb_id
  environment       = var.environment_name
  app_server_ids    = module.app_environment[0].app_server_ids # Passando os IDs para o anexo automático
  tags              = var.tags
  # certificate_arn removido: SSL offload na Cloudflare
}