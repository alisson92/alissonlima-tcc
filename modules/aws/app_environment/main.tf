# ======================================================================================
#   MÓDULO APP_ENVIRONMENT/MAIN.TF - VERSÃO CORRIGIDA PARA HA - (Alta Disponibilidade)
# ======================================================================================

# --- Servidor de Aplicação ---
resource "aws_instance" "app_server" {
  count = var.app_server_count

  ami                       = var.ami_id
  instance_type             = var.instance_type
  # <-- CORREÇÃO: Usa a variável correta (plural) para distribuir os servidores nas sub-redes.
  subnet_id                 = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  key_name                  = var.key_name
  vpc_security_group_ids    = [var.sg_application_id]
  disable_api_termination = true

  tags = merge(var.tags, {
    Name = "app-server-${count.index}-${var.environment}"
  })
}

# --- Servidor de Banco de Dados ---
resource "aws_instance" "db_server" {
  ami                       = var.ami_id
  instance_type             = var.instance_type
  # <-- CORREÇÃO: Coloca o DB server na primeira sub-rede privada da lista.
  subnet_id                 = var.private_subnet_ids[0]
  key_name                  = var.key_name
  vpc_security_group_ids    = [var.sg_application_id]
  disable_api_termination = true
  availability_zone         = var.db_server_availability_zone

  tags = merge(var.tags, {
    Name = "db-server-${var.environment}"
  })
}

# --- Anexa o disco ao servidor de banco de dados ---
resource "aws_volume_attachment" "db_data_attachment" {
  device_name = "/dev/sdf"
  volume_id   = var.db_volume_id
  instance_id = aws_instance.db_server.id
}

# Cria o registro DNS para o Servidor de Aplicação
resource "aws_route53_record" "app_server_dns" {
  # <-- MUDANÇA: Agora o DNS aponta para TODOS os servidores de aplicação.
  # O Route 53 vai distribuir as requisições entre eles (Round Robin).
  count   = var.app_server_count > 0 ? 1 : 0 # Cria apenas um registro DNS para o conjunto de servidores
  zone_id = var.private_zone_id
  name    = "app-server.${var.private_domain_name}" # Nome genérico, sem o nome do ambiente
  type    = "A"
  ttl     = 60
  records = aws_instance.app_server[*].private_ip # <-- CORREÇÃO: Pega a LISTA de IPs.
}

# Cria o registro DNS para o Servidor de Banco de Dados
resource "aws_route53_record" "db_server_dns" {
  zone_id = var.private_zone_id
  name    = "db-server.${var.private_domain_name}" # Nome genérico
  type    = "A"
  ttl     = 300
  records = [aws_instance.db_server.private_ip]
}