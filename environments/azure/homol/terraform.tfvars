# environments/aws/homol/terraform.tfvars
environment_name = "homol"
vpc_cidr_block   = "10.1.0.0/16" // CIDR DIFERENTE, ESSENCIAL!
instance_type    = "t2.micro"  // Ex: Instância maior
alb_dns_name     = "homol"
my_ip            = "45.230.208.30/32" // Seu IP, pode ser o mesmo
app_server_count = 1

tags = {
  Project   = "TCC-AlissonLima"
  ManagedBy = "Terraform"
  Env       = "homol" // Tag correta
}