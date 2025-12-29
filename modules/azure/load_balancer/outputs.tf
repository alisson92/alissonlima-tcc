output "lb_public_ip" {
  description = "O IP público do Load Balancer."
  value       = azurerm_public_ip.lb_pip.ip_address
}

output "backend_pool_id" {
  description = "O ID do Backend Address Pool."
  value       = azurerm_lb_backend_address_pool.main.id
}