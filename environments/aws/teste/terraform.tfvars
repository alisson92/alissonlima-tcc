# environments/aws/teste/terraform.tfvars
environment_name = "teste"
vpc_cidr_block   = "10.10.0.0/16"
instance_type    = "t2.micro"
alb_dns_name     = "teste"
my_ip            = "45.230.208.30/32" // Seu IP para acesso ao Bastion
app_server_count = 1

tags = {
  Project   = "TCC-AlissonLima"
  ManagedBy = "Terraform"
  Env       = "teste"
}