# =====================================================================
# ENVIRONMENTS/PROD/TERRAFORM.TFVARS - VALORES REAIS DO AMBIENTE
# =====================================================================

environment_name = "prod"

# Mudado para 10.70 para não conflitar com a Azure (10.10)
vpc_cidr_block   = "10.70.0.0/16" 

# t3.micro é a geração atual (mais rápida e barata que a t2)
instance_type    = "t3.micro" 

# Seu IP para acesso administrativo via Bastion
my_ip            = "45.230.208.30/32" 

# Quantidade de servidores de aplicação
app_server_count = 2

tags = {
  Project   = "TCC-AlissonLima"
  ManagedBy = "Terraform"
  Env       = "prod"
}

# --- Variáveis Adicionais (Centralizadas no Ambiente) ---
# Caso queira sobrescrever os defaults do variables.tf
ami_id   = "ami-0a7d80731ae1b2435"
key_name = "tcc-alisson-key"