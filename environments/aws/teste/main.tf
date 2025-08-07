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
  # Passando o CIDR da VPC para o módulo de segurança
  vpc_cidr_block = module.networking.vpc_cidr_block_output # Precisamos criar este output
  environment    = "teste"
  my_ip          = "45.230.208.30/32" 
}

# module "app_environment_teste" { ... } # Comentado por enquanto
