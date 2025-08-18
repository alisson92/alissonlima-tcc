# =====================================================================
#   MÓDULO APP_ENVIRONMENT/MAIN.TF - VERSÃO FINAL COM DNS ESPECIALIZADO
# =====================================================================

# --- Servidor de Aplicação ---
resource "aws_instance" "app_server" {
  count                     = var.app_server_count
  ami                       = var.ami_id
  instance_type             = var.instance_type
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

# --- Registros de DNS Privado ---

# 1. Registro GENÉRICO para a "frota" de servidores (para o Load Balancer, etc.)
resource "aws_route53_record" "app_server_dns_service" {
  count   = var.app_server_count > 0 ? 1 : 0
  zone_id = var.private_zone_id
  name    = "app-server.${var.private_domain_name}"
  type    = "A"
  ttl     = 60
  records = aws_instance.app_server[*].private_ip
}

# 2. <-- MUDANÇA: Registros INDIVIDUAIS para cada servidor (para acesso administrativo)
resource "aws_route53_record" "app_server_dns_admin" {
  count   = var.app_server_count # Cria um registro para cada servidor
  zone_id = var.private_zone_id
  name    = "app-server-${count.index}.${var.private_domain_name}" # Nome com índice: app-server-0, app-server-1, etc.
  type    = "A"
  ttl     = 300
  records = [aws_instance.app_server[count.index].private_ip] # IP específico de cada servidor
}

# 3. Registro para o servidor de banco de dados (continua igual)
resource "aws_route53_record" "db_server_dns" {
  zone_id = var.private_zone_id
  name    = "db-server.${var.private_domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.db_server.private_ip]
}