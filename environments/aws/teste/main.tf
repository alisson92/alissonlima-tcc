provider "aws" {
  region = "us-east-1"
}

module "networking" {
  source = "../../../modules/aws/networking"

  vpc_cidr_block = "10.10.0.0/16"
  environment    = "teste"
  aws_region     = "us-east-1"
}

module "security" {
  source = "../../../modules/aws/security"

  vpc_id         = module.networking.vpc_id
  vpc_cidr_block = "10.10.0.0/16" # Passando o CIDR para as regras simplificadas
  environment    = "teste"
  my_ip          = "45.230.208.30/32" # Lembre-se de colocar seu IP correto
}

# --- NOVO BLOCO ---  ## Adicionado em 07/08/2025
# Chama o módulo para criar os servidores do ambiente de teste
module "app_environment_teste" {
  source = "../../../modules/aws/app_environment"

  # Conectando as saídas dos outros módulos como entradas aqui
  environment       = "teste"
  private_subnet_id = module.networking.private_subnet_id
  sg_app_id         = module.security.sg_app_id
  sg_db_id          = module.security.sg_db_id

  # Lembre-se de verificar/criar estes pré-requisitos no console da AWS
  ami_id   = "ami-0a7d80731ae1b2435" # Ubuntu 22.04 LTS para us-east-1 (x86)
  key_name = "tcc-alisson-key"      
}
