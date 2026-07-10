## Motivação

O Bastion Host é o único recurso do ambiente com IP público e regra de
ingresso SSH — todo acesso administrativo a app/DB passa por ele via SSH
Agent Forwarding (ver `docs/ACESSOS.md`). Os registros de DNS foram
deliberadamente movidos para fora deste módulo (ver nota técnica no
`main.tf`) para evitar que ele dependa do provider `cloudflare`/DNS privado,
mantendo-o "100% independente" como o próprio comentário do código descreve.

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
| [azurerm_linux_virtual_machine.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.bastion_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.bastion_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Usuário padrão para login via SSH na VM do Bastion (Padronizado como 'ubuntu'). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | O nome do ambiente atual (ex: teste, homol, prod) para fins de nomenclatura. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | A região da Azure onde o Bastion Host será provisionado. | `string` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Conteúdo da chave pública SSH para autorizar o acesso à VM. | `string` | n/a | yes |
| <a name="input_public_subnet_id"></a> [public\_subnet\_id](#input\_public\_subnet\_id) | ID da sub-rede pública na VNet Azure onde o Bastion será alocado. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | O nome do Resource Group que conterá os recursos do Bastion. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Mapeamento de tags para organização e auditoria de recursos. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_id"></a> [bastion\_id](#output\_bastion\_id) | ID da VM do Bastion. |
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | O IP público do Bastion Host para acesso administrativo. |
<!-- END_TF_DOCS -->