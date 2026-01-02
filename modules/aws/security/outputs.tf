output "sg_bastion_id" {
  description = "ID do Security Group do Bastion Host (Necessário para o JIT SSH no pipeline)."
  value       = aws_security_group.bastion.id
}

output "sg_alb_id" {
  description = "ID do Security Group do Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "sg_application_id" {
  description = "ID do Security Group para os servidores de aplicação e comunicação interna de DB."
  value       = aws_security_group.application.id
}