## Motivação

Define os NSGs de Bastion e aplicação, espelhando o mesmo princípio de menor
privilégio do lado AWS: regras referenciam a origem por ID/tag de NSG, não por
CIDR aberto (exceção documentada: o NSG da aplicação aceita `*` na porta HTTP
pública, pois o tráfego legítimo chega de fora da VNet via Cloudflare → LB —
ver achado do Trivy em `docs/CI-QUALIDADE.md`). O invariante de referência por
ID é verificado automaticamente pelos testes deste módulo
(`tests/main.tftest.hcl`).

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
| [azurerm_network_security_group.application](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_subnet_network_security_group_association.app_a](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.app_b](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Nome do ambiente (ex: teste, homol, prod) para usar nas tags. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Região da Azure (Ex: East US). | `string` | n/a | yes |
| <a name="input_my_ip"></a> [my\_ip](#input\_my\_ip) | Seu endereço IP público para permitir acesso SSH ao Bastion Host. | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Lista de IDs das sub-redes privadas vindas do módulo de networking. | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Lista de IDs das sub-redes públicas vindas do módulo de networking. | `list(string)` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Nome do Resource Group onde os NSGs serão criados. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Um mapa de tags para ser aplicado nos recursos. | `map(string)` | `{}` | no |
| <a name="input_vnet_cidr_block"></a> [vnet\_cidr\_block](#input\_vnet\_cidr\_block) | O bloco CIDR da VNet para usar nas regras de segurança. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_nsg_application_id"></a> [nsg\_application\_id](#output\_nsg\_application\_id) | ID do Network Security Group unificado para a aplicação (App e DB). |
| <a name="output_nsg_bastion_id"></a> [nsg\_bastion\_id](#output\_nsg\_bastion\_id) | ID do Network Security Group do Bastion Host. |
<!-- END_TF_DOCS -->