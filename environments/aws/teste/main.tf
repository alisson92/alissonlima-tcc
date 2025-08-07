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

  vpc_id      = module.networking.vpc_id
  environment = "teste"
  my_ip       = "45.230.208.30" # Lembre-se de manter seu IP correto aqui
}

# --- NOVO BLOCO ---
# Chama o módulo para criar o par de servidores do ambiente de teste
module "app_environment_teste" {
  source = "../../../modules/aws/app_environment"

  # Conectando as saídas dos outros módulos como entradas aqui
  environment       = "teste"
  private_subnet_id = module.networking.private_subnet_id
  sg_app_id         = module.security.sg_app_id
  sg_db_id          = module.security.sg_db_id

  # Preencha com os valores que você pegou no Passo 1
  ami_id   = "ami-0c55b159cbfafe1f0" # <-- SUBSTITUA PELO ID DA AMI DO UBUNTU 22.04 NA SUA REGIÃO
  key_name = "tcc-alisson-key"       # <-- SUBSTITUA PELO NOME DO SEU PAR DE CHAVES
}