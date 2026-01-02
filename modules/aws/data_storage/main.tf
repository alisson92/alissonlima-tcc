# =====================================================================
# MÓDULO DATA_STORAGE - PERSISTÊNCIA DE DADOS (EBS)
# =====================================================================

resource "aws_ebs_volume" "db_data" {
  availability_zone = var.az
  size              = var.volume_size
  type              = "gp3" # Performance moderna e custo-benefício para o banco

  # A TRAVA DE SEGURANÇA VIVE AQUI, PERMANENTEMENTE
  # Excelente para o TCC: demonstra que o dado sobrevive à destruição da instância.
  lifecycle {
    prevent_destroy = false
  }

  tags = merge(var.tags, {
    Name = "ebs-tcc-db-data-${var.environment}"
  })
}