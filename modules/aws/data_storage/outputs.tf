# =====================================================================
# MÓDULO DATA_STORAGE - OUTPUTS (PERSISTÊNCIA)
# =====================================================================

output "volume_id" {
  description = "O ID do volume EBS criado. Este valor é injetado no módulo app_environment para o anexo físico ao banco de dados."
  value       = aws_ebs_volume.db_data.id
}