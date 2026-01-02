output "bastion_public_ip" {
  description = "O endereço IP público do Bastion Host (Necessário para o DNS e para o ProxyCommand do Ansible)."
  value       = aws_instance.bastion_host.public_ip
}

output "bastion_instance_id" {
  description = "O ID da instância do Bastion Host."
  value       = aws_instance.bastion_host.id
}