provider "aws" {
  region = "us-east-1"
}

# Data source para buscar automaticamente as informações do seu domínio no Route 53
data "aws_route53_zone" "primary" {
  name = "alissonlima.dev.br"
}

# --- CAMADA 1: REDE ---
module "networking" {
  source = "../../../modules/aws/networking"

  vpc_cidr_block = "10.10.0.0/16"
  environment    = "teste"
  aws_region     = "us-east-1"
}

# --- CAMADA 2: SEGURANÇA ---
module "security" {
  source = "../../../modules/aws/security"

  # Conexões com o módulo de rede
  vpc_id         = module.networking.vpc_id
  vpc_cidr_block = module.networking.vpc_cidr_block_output

  # Variáveis do ambiente
  environment    = "teste"
  my_ip          = "45.230.208.30/32" # Lembre-se de manter seu IP correto
}

# --- CAMADA 3: ARMAZENAMENTO PERSISTENTE ---
module "data_storage_teste" {
  source = "../../../modules/aws/data_storage"

  environment                 = "teste"
  # Garante que o volume seja criado na mesma Zona de Disponibilidade da sub-rede privada
  db_server_availability_zone = module.networking.private_subnet_availability_zone
}

# --- CAMADA 4: COMPUTAÇÃO (Servidores) ---
module "app_environment_teste" {
  source = "../../../modules/aws/app_environment"

  # Conexões com outros módulos
  environment       = "teste"
  private_subnet_id = module.networking.private_subnet_id
  
  # --- CORREÇÃO APLICADA AQUI ---
  # Removemos sg_app_id e sg_db_id e usamos a nova saída unificada
  sg_application_id = module.security.sg_application_id 
  
  db_volume_id      = module.data_storage_teste.volume_id

  # Parâmetros de configuração das VMs
  ami_id   = "ami-0a7d80731ae1b2435" # Ubuntu 22.04 LTS para us-east-1 (x86)
  key_name = "tcc-alisson-key"
}

# --- CAMADA 5: PONTO DE ACESSO ---
module "bastion_host_teste" {
  source = "../../../modules/aws/bastion"

  # Conexões com outros módulos
  public_subnet_id = module.networking.public_subnet_id
  sg_bastion_id    = module.security.sg_bastion_id
  zone_id          = data.aws_route53_zone.primary.zone_id
  domain_name      = data.aws_route53_zone.primary.name

  # Variáveis do ambiente
  environment      = "teste"

  # Parâmetros de configuração da VM
  ami_id   = "ami-0a7d80731ae1b2435"
  key_name = "tcc-alisson-key"
}
