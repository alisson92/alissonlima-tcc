provider "aws" {
  region = "us-east-1"
}

data "aws_route53_zone" "primary" {
  name = "alissonlima.dev.br"
}

# --- CAMADA 1: REDE ---
# Este módulo cria uma rede altamente disponível com sub-redes em duas AZs.
module "networking" {
  count  = var.create_environment ? 1 : 0
  source = "../../../modules/aws/networking"

  vpc_cidr_block = "10.10.0.0/16"
  environment    = "teste"
  aws_region     = "us-east-1"
}

# --- CAMADA 2: SEGURANÇA ---
module "security" {
  count          = var.create_environment ? 1 : 0
  source         = "../../../modules/aws/security"

  vpc_id         = module.networking[0].vpc_id
  vpc_cidr_block = module.networking[0].vpc_cidr_block_output
  environment    = "teste"
  my_ip          = "45.230.208.30/32"
}

# --- CAMADA 2.5: DNS PRIVADO ---
# Cria a "lista telefónica" que só funciona dentro da VPC
resource "aws_route53_zone" "private" {
  count = var.create_environment ? 1 : 0
  name  = "internal.alissonlima.dev.br"

  vpc {
    vpc_id = module.networking[0].vpc_id
  }
}

# --- CAMADA 3: ARMAZENAMENTO PERSISTENTE (SEM COUNT) ---
module "data_storage_teste" {
  source                      = "../../../modules/aws/data_storage"
  environment                 = "teste"
  db_server_availability_zone = var.create_environment ? module.networking[0].private_subnet_availability_zone : "us-east-1a"
}

# --- CAMADA 4: COMPUTAÇÃO (Servidores) ---
module "app_environment_teste" {
  count             = var.create_environment ? 1 : 0
  source            = "../../../modules/aws/app_environment"

  environment       = "teste"
  private_subnet_id = module.networking[0].private_subnet_ids[0] # Usa a primeira sub-rede privada
  sg_application_id = module.security[0].sg_application_id
  db_volume_id      = module.data_storage_teste.volume_id
  ami_id            = "ami-0a7d80731ae1b2435"
  key_name          = "tcc-alisson-key"

# --- CORREÇÃO APLICADA ---
  # Passamos a mesma AZ para o servidor de banco, garantindo consistência.
  db_server_availability_zone = var.create_environment ? module.networking[0].private_subnet_availability_zone : "us-east-1a"

  # --- LIGAÇÕES DE DNS PRIVADO ---
  private_zone_id     = aws_route53_zone.private[0].zone_id
  private_domain_name = aws_route53_zone.private[0].name
}

# --- CAMADA 5: PONTO DE ACESSO (BASTION) ---
module "bastion_host_teste" {
  count            = var.create_environment ? 1 : 0
  source           = "../../../modules/aws/bastion"

  public_subnet_id = module.networking[0].public_subnet_ids[0] # Usa a primeira sub-rede pública
  sg_bastion_id    = module.security[0].sg_bastion_id
  zone_id          = data.aws_route53_zone.primary.zone_id
  domain_name      = data.aws_route53_zone.primary.name
  environment      = "teste"
  ami_id           = "ami-0a7d80731ae1b2435"
  key_name         = "tcc-alisson-key"
}

# --- CAMADA 6: PONTO DE ENTRADA DA APLICAÇÃO (ALB) ---
module "load_balancer_teste" {
  count             = var.create_environment ? 1 : 0
  source            = "../../../modules/aws/load_balancer"

  vpc_id            = module.networking[0].vpc_id
  public_subnet_ids = module.networking[0].public_subnet_ids # Passa a lista de sub-redes públicas
  sg_alb_id         = module.security[0].sg_alb_id
  environment       = "teste"
}

# --- CAMADA 7: CONEXÕES FINAIS ---
resource "aws_lb_target_group_attachment" "app_server" {
  count            = var.create_environment ? 1 : 0
  target_group_arn = module.load_balancer_teste[0].target_group_arn
  target_id        = module.app_environment_teste[0].app_server_id
  port             = 80
}

resource "aws_route53_record" "app_dns" {
  count   = var.create_environment ? 1 : 0
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "teste.alissonlima.dev.br"
  type    = "A"

  alias {
    name                   = module.load_balancer_teste[0].alb_dns_name
    zone_id                = module.load_balancer_teste[0].alb_zone_id
    evaluate_target_health = true
  }
}