output "bastion_public_ip" {
  description = "O IP público do Bastion Host."
  value       = aws_instance.bastion_host.public_ip
}