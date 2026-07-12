output "lb_public_ip" {
  description = "O IP público do Application Gateway."
  value       = azurerm_public_ip.lb_ip.ip_address
}
