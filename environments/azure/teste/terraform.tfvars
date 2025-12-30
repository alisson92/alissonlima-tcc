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
public_key            = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgdXWG9NqgSi1vCZzQ5bY8X/pbnfBEiiUqDMLdBR4yYGkd6RLmCfV/9QyTkd3U4pfSHtOmDyrtNoNdXdO5nIX2kierwQ0znLiS26cYG1xvjfhfn10I9SKfGo/7QGkJ6afR2Zlooc1Lw/zVKGpP44E+hnSIq0BaDOuNQ2rgT8brqACJT1y3TYu6t3hwXZdpeEm/lv0g/1nBDuW6xemS2kowesk6VVastqIn9zrB0GQeAWg2cLHT/WABCBdE71W+atso1dZ3JyR2fh1KSsAKe33BCYSJHTtCoeNNlsEBiKR8eTImE14FA1ajzVobbZ5msrYam8pyojUvoqGAFxX8l5eD/SXqMpwY+GDVKzcuknkK4+gcX0C6dupXa/LKGSGAjjAOG6CoUXjNntAgNmwjqbd51xaLRuXe8Gnuk0n9Tf81YTVsbYynbFolBCueCi/2LG8mMfgcPHSNGjSaVIszmmwLmdfIPvwsEzYgJJlMVSibJcjou88ibQ6tuld6NWdaHVP+x9PNr/OyjQE3zoIE5ySpJSxCwGqZRxNa5nB50p6VmliIoIs1tmFDvZI/bWfWwXE/cltm4kwCYSBU3toayVNhuJ5t+wwLJwq0iRuduTiuVrdT4LuYyPxul7CQjhn1dCCFUDFTOd8xD8/EpqKl3Ro7pLqWss8erwjDeNKMB2L3ew== adminuser" 

# --- Metadados e Tags ---
tags = {
  Project   = "TCC-AlissonLima-Azure"
  ManagedBy = "Terraform"
  Env       = "teste"
}

# --- Credenciais Cloudflare (Automação de DNS/SSL) ---
# Substitua os valores abaixo pelos seus dados reais da Cloudflare
cloudflare_api_token = "RO3VU8wqe9eYyWF8omAig4wlpYN0gPRXt55XIBOl"
cloudflare_zone_id    = "1a1c290f0f787a922cd6bfd4285d7ae9"