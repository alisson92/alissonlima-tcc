# --- Servidor de Aplicação ---
resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type_app
  subnet_id              = var.private_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.sg_app_id]

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
  vpc_security_group_ids = [var.sg_db_id]

  tags = {
    Name = "db-server-${var.environment}"
  }
}

# --- Disco Persistente para o Banco de Dados (SIMPLIFICADO) ---
resource "aws_ebs_volume" "db_data" {
  availability_zone = aws_instance.db_server.availability_zone
  size              = 10
  type              = "gp3"

  # SEM o bloco lifecycle aqui dentro

  tags = {
    Name = "ebs-db-data-${var.environment}"
  }
}

# --- Anexa o disco ao servidor de banco de dados ---
resource "aws_volume_attachment" "db_data_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.db_data.id
  instance_id = aws_instance.db_server.id
}
