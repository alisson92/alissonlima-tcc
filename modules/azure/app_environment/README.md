## Motivação

Provisiona o(s) servidor(es) de aplicação (`app_server_count`) e o servidor de
banco de dados como VMs Linux, cada uma com sua própria NIC dedicada (a Azure,
diferente da AWS, exige a interface de rede como recurso explícito e separado
da VM). Ambos ficam restritos à sub-rede privada. Assim como no módulo
equivalente da AWS, este módulo não cria registros de DNS — isso é feito no
`dns.tf` do ambiente, mantendo o módulo reutilizável e testável de forma
isolada.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.80.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_linux_virtual_machine.app_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_linux_virtual_machine.db_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.app_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.db_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_virtual_machine_data_disk_attachment.db_data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_server_count"></a> [app\_server\_count](#input\_app\_server\_count) | Quantidade de servidores de aplicação a serem criados. | `number` | `1` | no |
| <a name="input_db_disk_id"></a> [db\_disk\_id](#input\_db\_disk\_id) | ID do Managed Disk para o banco de dados. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Nome do ambiente (ex: teste, homol, prod). | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Região da Azure. | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Lista de IDs das sub-redes privadas onde as VMs serão criadas. | `list(string)` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Conteúdo da chave pública SSH. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Nome do Resource Group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Um mapa de tags para ser aplicado nos recursos. | `map(string)` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Tamanho da VM (Ex: Standard\_B2ts\_v2). | `string` | `"Standard_B2ts_v2"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_app_server_ids"></a> [app\_server\_ids](#output\_app\_server\_ids) | Lista de IDs das VMs de aplicação. |
| <a name="output_app_server_nic_ids"></a> [app\_server\_nic\_ids](#output\_app\_server\_nic\_ids) | Lista de IDs das interfaces de rede (NICs) das VMs de aplicação. |
| <a name="output_app_server_private_ips"></a> [app\_server\_private\_ips](#output\_app\_server\_private\_ips) | Lista de IPs privados das VMs de aplicação. |
| <a name="output_db_server_id"></a> [db\_server\_id](#output\_db\_server\_id) | O ID da VM do servidor de banco de dados. |
| <a name="output_db_server_private_ip"></a> [db\_server\_private\_ip](#output\_db\_server\_private\_ip) | O IP privado do servidor de banco de dados. |
<!-- END_TF_DOCS -->