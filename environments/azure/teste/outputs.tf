output "bastion_public_ip" {
  value = module.bastion_host.bastion_public_ip
}

output "lb_public_ip" {
  value = module.load_balancer.lb_public_ip
}

output "app_server_private_ips" {
  value = module.app_environment.app_server_private_ips
}