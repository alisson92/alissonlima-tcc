output "alb_dns_name" {
  description = "O nome DNS do Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "O ID da Hosted Zone do Application Load Balancer."
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "O ARN do Target Group principal."
  value       = aws_lb_target_group.main.arn
}