# =====================================================================
# MÓDULO APP_ENVIRONMENT - INFRAESTRUTURA PURA (SEM DEPENDÊNCIA DE DNS)
# =====================================================================

# --- 1. Servidores de Aplicação ---
resource "aws_instance" "app_server" {
  count                   = var.app_server_count
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  key_name                = var.key_name
  vpc_security_group_ids  = [var.sg_application_id]
  disable_api_termination = false # Alterado para permitir destruição via pipeline se necessário

  tags = merge(var.tags, {
    Name = "app-server-tcc-${count.index}-${var.environment}"
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    tags = merge(var.tags, {
      Name = "disk-app-tcc-${count.index}-${var.environment}"
    })
  }
}

# --- 2. Servidor de Banco de Dados ---
resource "aws_instance" "db_server" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.private_subnet_ids[0] # Mantido na primeira subnet privada
  key_name                = var.key_name
  vpc_security_group_ids  = [var.sg_application_id]
  disable_api_termination = false
  availability_zone       = var.db_server_availability_zone

  tags = merge(var.tags, {
    Name = "db-server-tcc-${var.environment}"
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    tags = merge(var.tags, {
      Name = "disk-db-tcc-${var.environment}"
    })
  }
}

# --- 3. Anexo do Volume de Dados (Persistência) ---
resource "aws_volume_attachment" "db_data_attachment" {
  device_name = "/dev/sdf"
  volume_id   = var.db_volume_id
  instance_id = aws_instance.db_server.id
}