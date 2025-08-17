# --- Disco Persistente para o Banco de Dados (O "Volume") ---
resource "aws_ebs_volume" "db_data" {
  availability_zone = var.db_server_availability_zone
  size              = 10 
  type              = "gp3"

  # A TRAVA DE SEGURANÇA VIVE AQUI, PERMANENTEMENTE
  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.tags, {
    Name = "ebs-db-data-${var.environment}"
  })
}