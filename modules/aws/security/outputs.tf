output "sg_bastion_id" {
  value = aws_security_group.bastion.id
}

# Comente ou apague o bloco abaixo por enquanto
# output "sg_alb_id" {
#  value = aws_security_group.alb.id
# }

output "sg_app_id" {
  value = aws_security_group.app.id
}

output "sg_db_id" {
  value = aws_security_group.db.id
}
