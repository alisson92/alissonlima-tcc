environment_name = "prod"
vpc_cidr_block   = "10.2.0.0/16"    # Bloco de IPs exclusivo para produção
instance_type    = "t2.micro"      # Instâncias mais robustas
alb_dns_name     = "prod"            # URL final será https://prod.alissonlima.dev.br
my_ip            = "45.230.208.30/32" # Garanta que seu IP atual esteja aqui
app_server_count = 2

tags = {
  Project   = "TCC-AlissonLima"
  ManagedBy = "Terraform"
  Env       = "prod" # Tag CRÍTICA para identificar os recursos
}