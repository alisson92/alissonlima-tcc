# environments/aws/teste/terraform.tfvars
environment_name = "teste"
vpc_cidr_block   = "10.10.0.0/16"
instance_type    = "t3.micro"
alb_dns_name     = "teste"
my_ip            = "45.230.200.30/32" // Seu IP para acesso ao Bastion
tags = {
  Project   = "TCC-AlissonLima"
  ManagedBy = "Terraform"
  Env       = "teste"
}