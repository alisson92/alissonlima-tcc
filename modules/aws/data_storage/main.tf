# =====================================================================
# MÓDULO DATA_STORAGE - PERSISTÊNCIA DE DADOS (EBS)
# =====================================================================

resource "aws_ebs_volume" "db_data" {
  availability_zone = var.az
  size              = var.volume_size
  type              = "gp3" # Performance moderna e melhor custo-benefício

  # REMOVIDO: lifecycle { prevent_destroy = true }
  # MOTIVO TCC: Padronização com Azure para permitir automação total 
  # de criação e destruição (Elasticidade e FinOps).

  tags = merge(var.tags, {
    Name = "ebs-tcc-db-data-${var.environment}"
  })
}