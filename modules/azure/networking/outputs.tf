output "vnet_id" {
  description = "O ID da Virtual Network criada."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "O nome da Virtual Network."
  value       = azurerm_virtual_network.main.name
}

output "public_subnet_ids" {
  description = "Lista de IDs das sub-redes públicas."
  value       = [azurerm_subnet.public_a.id, azurerm_subnet.public_b.id]
}

output "private_subnet_ids" {
  description = "Lista de IDs das sub-redes privadas."
  value       = [azurerm_subnet.private_a.id, azurerm_subnet.private_b.id]
}

output "location" {
  description = "A localização onde a rede foi criada."
  value       = azurerm_virtual_network.main.location
}
