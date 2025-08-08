output "sg_bastion_id" {
  description = "ID do Security Group do Bastion Host."
  value       = aws_security_group.bastion.id
}

output "sg_alb_id" {
  description = "ID do Security Group do Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "sg_application_id" {
  description = "ID do Security Group unificado para a aplicacao (App e DB)."
  value       = aws_security_group.application.id
}
