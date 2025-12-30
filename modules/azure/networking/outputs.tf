output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "public_subnet_ids" {
  value = [azurerm_subnet.public_a.id, azurerm_subnet.public_b.id]
}

output "private_subnet_ids" {
  value = [azurerm_subnet.private_a.id, azurerm_subnet.private_b.id]
}

# ESSENCIAIS PARA O DNS QUE CRIAMOS
output "public_dns_zone_name" {
  value = azurerm_dns_zone.public.name
}

output "private_dns_zone_name" {
  value = azurerm_private_dns_zone.internal.name
}

output "azure_nameservers" {
  description = "Nameservers para cadastrar no Registro.br"
  value       = azurerm_dns_zone.public.name_servers
}