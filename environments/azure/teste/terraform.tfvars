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
public_key            = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUtHNYGDGvKXW8qRkwLm+6gFcJFdASU1NAg26q0ayh9cTK+UHHeG1wEYaE+OA+UxjCOALQsVScj5d0ptHOmYIEcVhCyxzkeN7S1ll94iJjIOiLQcQyQxrQ1cYKKlCzU0/BrascUi7vIDLwV2oirykLjZmrlo/MCldyNOIzvvDe9wdxkfrKDjIWFV7TSy5b4CNwldUEYoL/Sl1tyEdgl9Xsau9vuXEXmdIx6iu6B/27SHMht4TXQDfPxs31H9sszYcr7LzUIycCb14AOFZsZzjgkNSYuGCngGO005fxq/BOtNZCdGOfZ9RdLU1ffDA3f2Fbacztn+nn6eaMMeirYqB3" 

# --- Metadados e Tags ---
tags = {
  Project   = "TCC-AlissonLima-Azure"
  ManagedBy = "Terraform"
  Env       = "teste"
}