# --- Servidor de Aplicação ---
resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type_app
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.sg_application_id]

  disable_api_termination = true

  tags = {
    Name = "app-server-${var.environment}"
  }
}

# --- Servidor de Banco de Dados ---
resource "aws_instance" "db_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type_db
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.sg_application_id]

  disable_api_termination = true

  tags = {
    Name = "db-server-${var.environment}"
  }
}

# --- Anexa o disco ao servidor de banco de dados ---
resource "aws_volume_attachment" "db_data_attachment" {
  device_name = "/dev/sdf"
  volume_id   = var.db_volume_id
  instance_id = aws_instance.db_server.id
}

# Cria o registro DNS para o Servidor de Aplicação
resource "aws_route53_record" "app_server_dns" {
  zone_id = var.private_zone_id
  name    = "app-server.${var.environment}.${var.private_domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.app_server.private_ip]
}

# Cria o registro DNS para o Servidor de Banco de Dados
resource "aws_route53_record" "db_server_dns" {
  zone_id = var.private_zone_id
  name    = "db-server.${var.environment}.${var.private_domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.db_server.private_ip]
}
