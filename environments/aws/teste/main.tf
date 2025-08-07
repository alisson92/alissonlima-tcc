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
  my_ip       = "45.230.208.30" # Verifique se este valor está 100% correto
}

module "app_environment_teste" {
  source = "../../../modules/aws/app_environment"

  environment       = "teste"
  private_subnet_id = module.networking.private_subnet_id
  sg_app_id         = module.security.sg_app_id
  sg_db_id          = module.security.sg_db_id
  ami_id            = "ami-da7a780751ae1b2435" # Ubuntu 22.04 LTS para us-east-1 (x86)
  key_name          = "tcc-alisson-key"      # Verifique se este é o nome exato do seu par de chaves
}
