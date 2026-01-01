# =====================================================================
# MÓDULO LOAD BALANCER - OUTPUTS (PONTOS DE INTEGRAÇÃO EXTERNA)
# =====================================================================

output "alb_dns_name" {
  description = "Nome DNS do ALB. Use este valor para criar o CNAME na Cloudflare (Ex: app.alissonlima.dev.br -> alb-tcc...)."
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ID da Hosted Zone do ALB (Necessário caso decida usar o Route 53 no futuro)."
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN do Target Group (Útil para integração com Auto Scaling ou logs de auditoria)."
  value       = aws_lb_target_group.main.arn
}

output "alb_arn" {
  description = "ARN do Load Balancer para fins de monitoramento e métricas."
  value       = aws_lb.main.arn
}