output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "public_subnet_ids" {
  value = [azurerm_subnet.public_a.id]
}

output "private_subnet_ids" {
  value = [azurerm_subnet.private_a.id, azurerm_subnet.private_b.id]
}

output "appgw_subnet_id" {
  description = "ID da subnet dedicada ao Application Gateway (não pode ter outro recurso associado)."
  value       = azurerm_subnet.appgw.id
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