environment_name = "prod"
vpc_cidr_block   = "10.2.0.0/16"    # Bloco de IPs exclusivo para produção
instance_type    = "t3.medium"      # Instâncias mais robustas
alb_dns_name     = "app"            # URL final será https://app.alissonlima.dev.br
my_ip            = "45.230.208.30/32" # Garanta que seu IP atual esteja aqui

tags = {
  Project   = "TCC-AlissonLima"
  ManagedBy = "Terraform"
  Env       = "prod" # Tag CRÍTICA para identificar os recursos
}