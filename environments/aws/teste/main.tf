provider "aws" {
  region = "us-east-1"
}

data "aws_route53_zone" "primary" {
  name = "alissonlima.dev.br"
}

# --- CAMADA 1: REDE ---
module "networking" {
  count  = var.create_environment ? 1 : 0
  source = "../../../modules/aws/networking"
  # ... (o resto das variáveis como antes)
}

# --- CAMADA 2: SEGURANÇA ---
module "security" {
  count          = var.create_environment ? 1 : 0
  source         = "../../../modules/aws/security"
  vpc_id         = module.networking[0].vpc_id # Usa o índice [0] por causa do count
  vpc_cidr_block = module.networking[0].vpc_cidr_block_output
  # ... (o resto das variáveis como antes)
}

# --- CAMADA 3: ARMAZENAMENTO PERSISTENTE (SEM COUNT) ---
module "data_storage_teste" {
  source                      = "../../../modules/aws/data_storage"
  environment                 = "teste"
  db_server_availability_zone = var.create_environment ? module.networking[0].private_subnet_availability_zone : "us-east-1b" # Lógica para evitar erro quando a rede não existe
}

# --- CAMADA 4: COMPUTAÇÃO ---
module "app_environment_teste" {
  count             = var.create_environment ? 1 : 0
  source            = "../../../modules/aws/app_environment"
  sg_application_id = module.security[0].sg_application_id
  db_volume_id      = module.data_storage_teste.volume_id
  # ... (o resto das variáveis como antes)
}

# --- CAMADA 5: PONTO DE ACESSO ---
module "bastion_host_teste" {
  count            = var.create_environment ? 1 : 0
  source           = "../../../modules/aws/bastion"
  public_subnet_id = module.networking[0].public_subnet_id
  sg_bastion_id    = module.security[0].sg_bastion_id
  # ... (o resto das variáveis como antes)
}
