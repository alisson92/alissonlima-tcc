# --- Lógica de Controle (Padrão TCC) ---
create_environment = true
persist_db_volume  = true

# --- Definições do Ambiente ---
environment_name = "teste"
vnet_cidr_block  = "10.20.0.0/16" 
location         = "eastus"           # Ajustado para o formato slug
instance_type    = "Standard_B1s"
app_server_count = 1

# --- Redes e Segurança ---
my_ip            = "45.230.208.30/32" # Mantendo o seu IP com o sufixo /32

# --- DNS e Acesso ---
lb_dns_name           = "teste"
private_dns_zone_name = "internal.alissonlima.dev.br"
# Lembre-se de colar o conteúdo COMPLETO da sua id_rsa.pub abaixo
public_key            = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGawuMAaHgqcBk2DbXtxK/yPOCqEvSP+fyIbilipEuzI adminuser" 

# --- Metadados e Tags ---
tags = {
  Project   = "TCC-AlissonLima-Azure"
  ManagedBy = "Terraform"
  Env       = "teste"
}