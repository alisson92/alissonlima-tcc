# =====================================================================
#   ENVIRONMENTS/HOMOL/MAIN.TF - VERSÃO CORRIGIDA E CONSISTENTE
# =====================================================================

provider "aws" {
  region = "us-east-1"
}

data "aws_route53_zone" "primary" {
  name = "alissonlima.dev.br"
}

# --- CAMADA 1: REDE ---
module "networking" {
  count          = var.create_environment ? 1 : 0
  source         = "../../../modules/aws/networking"
  vpc_cidr_block = var.vpc_cidr_block
  environment    = var.environment_name
  tags           = var.tags
  aws_region     = "us-east-1"
}

# --- CAMADA 2: SEGURANÇA ---
module "security" {
  count          = var.create_environment ? 1 : 0
  source         = "../../../modules/aws/security"
  vpc_id         = module.networking[0].vpc_id
  vpc_cidr_block = module.networking[0].vpc_cidr_block_output
  environment    = var.environment_name
  my_ip          = var.my_ip
  tags           = var.tags
}

# --- CAMADA 2.5: DNS PRIVADO ---
resource "aws_route53_zone" "private" {
  count = var.create_environment ? 1 : 0
  name  = "internal.alissonlima.dev.br"

  vpc {
    vpc_id = module.networking[0].vpc_id
  }
}

# --- CAMADA 3: ARMAZENAMENTO PERSISTENTE (SEM COUNT) ---
module "data_storage" {
  source                      = "../../../modules/aws/data_storage"
  environment                 = var.environment_name
  db_server_availability_zone = var.create_environment ? module.networking[0].private_subnet_availability_zone : "us-east-1a"
  tags                        = var.tags
}

# --- CAMADA 4: COMPUTAÇÃO (Servidores) ---
module "app_environment" {
  count = var.create_environment ? 1 : 0
  source                    = "../../../modules/aws/app_environment"
  
  # Como 'homol' só tem 1 servidor (por padrão), não precisamos passar 'app_server_count'.
  
  # <-- CORREÇÃO: Passando a LISTA completa de sub-redes.
  private_subnet_ids        = module.networking[0].private_subnet_ids

  environment               = var.environment_name
  instance_type             = var.instance_type
  sg_application_id         = module.security[0].sg_application_id
  db_volume_id              = module.data_storage.volume_id
  ami_id                    = "ami-0a7d80731ae1b2435"
  key_name                  = "tcc-alisson-key"
  db_server_availability_zone = var.create_environment ? module.networking[0].private_subnet_availability_zone : "us-east-1a"
  private_zone_id           = aws_route53_zone.private[0].zone_id
  private_domain_name       = aws_route53_zone.private[0].name
  tags                      = var.tags
}

# --- CAMADA 5: PONTO DE ACESSO (BASTION) ---
module "bastion_host" {
  count              = var.create_environment ? 1 : 0
  source             = "../../../modules/aws/bastion"
  public_subnet_id   = module.networking[0].public_subnet_ids[0]
  sg_bastion_id      = module.security[0].sg_bastion_id
  zone_id            = data.aws_route53_zone.primary.zone_id
  domain_name        = data.aws_route53_zone.primary.name
  environment        = var.environment_name
  ami_id             = "ami-0a7d80731ae1b2435"
  key_name           = "tcc-alisson-key"
  tags               = var.tags
}

# --- CAMADA 6: PONTO DE ENTRADA DA APLICAÇÃO (ALB) ---
module "load_balancer" {
  count             = var.create_environment ? 1 : 0
  source            = "../../../modules/aws/load_balancer"
  vpc_id            = module.networking[0].vpc_id
  public_subnet_ids = module.networking[0].public_subnet_ids
  sg_alb_id         = module.security[0].sg_alb_id
  environment       = var.environment_name
  certificate_arn   = "arn:aws:acm:us-east-1:531390799560:certificate/79ae68b0-3105-48af-939c-f521fe926823"
  tags              = var.tags
}

# --- CAMADA 7: CONEXÕES FINAIS ---
resource "aws_lb_target_group_attachment" "app_server" {
  count            = var.create_environment ? 1 : 0
  target_group_arn = module.load_balancer[0].target_group_arn
  # <-- CORREÇÃO: Usando a saída de lista 'app_server_ids' e pegando o primeiro (e único) item.
  target_id        = module.app_environment[0].app_server_ids[0]
  port             = 80
}

resource "aws_route53_record" "app_dns" {
  count   = var.create_environment ? 1 : 0
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${var.alb_dns_name}.${data.aws_route53_zone.primary.name}"
  type    = "A"

  alias {
    name                   = module.load_balancer[0].alb_dns_name
    zone_id                = module.load_balancer[0].alb_zone_id
    evaluate_target_health = true
  }
}