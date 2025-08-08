# --- Servidor de Aplicação ---
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type_app
  subnet_id     = var.private_subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [var.sg_app_id]

  tags = {
    Name = "app-server-${var.environment}"
  }
}

# --- Servidor de Banco de Dados ---
resource "aws_instance" "db_server" {
  ami           = var.ami_id
  instance_type = var.instance_type_db
  subnet_id     = var.private_subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [var.sg_db_id]

  tags = {
    Name = "db-server-${var.environment}"
  }
}

# --- Disco Persistente para o Banco de Dados (O "Volume") ---

# Recurso 1: O Volume PROTEGIDO
# Este recurso só será criado se var.persist_db_volume for true.
resource "aws_ebs_volume" "db_data_protected" {
  count = var.persist_db_volume ? 1 : 0 # A mágica do count: cria 1 se true, 0 se false

  availability_zone = aws_instance.db_server.availability_zone
  size              = 10
  type              = "gp3"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "ebs-db-data-${var.environment}"
  }
}

# Recurso 2: O Volume DESPROTEGIDO (para permitir o destroy)
# Este recurso só será criado se var.persist_db_volume for false.
resource "aws_ebs_volume" "db_data_unprotected" {
  count = var.persist_db_volume ? 0 : 1 # A lógica invertida: cria 0 se true, 1 se false

  availability_zone = aws_instance.db_server.availability_zone
  size              = 10
  type              = "gp3"

  # Sem o bloco lifecycle, este volume pode ser destruído.

  tags = {
    Name = "ebs-db-data-${var.environment}"
  }
}

# --- Anexa o disco ao servidor de banco de dados ---
resource "aws_volume_attachment" "db_data_attachment" {
  device_name = "/dev/sdf"
  # Usa uma lógica para pegar o ID do volume que foi de fato criado
  volume_id   = var.persist_db_volume ? aws_ebs_volume.db_data_protected[0].id : aws_ebs_volume.db_data_unprotected[0].id
  instance_id = aws_instance.db_server.id
}
