## Motivação

O Azure Load Balancer (Standard SKU) expõe uma regra HTTP (porta 80), sem
HTTPS — decisão intencional, não uma lacuna: o SSL/TLS é terminado na
Cloudflare antes do tráfego chegar ao LB (ver seção "DNS split" do
`CLAUDE.md`). Backend pool e health probe seguem a topologia padrão do
Azure LB, equivalente ao Target Group + health check do ALB na AWS.

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
| [azurerm_lb.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.app_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.http](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.http](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_public_ip.lb_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Nome do ambiente (ex: teste). | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Localização/Região da Azure. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Nome do Resource Group na Azure. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Mapa de tags para os recursos. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_backend_pool_id"></a> [backend\_pool\_id](#output\_backend\_pool\_id) | O ID do Backend Address Pool. |
| <a name="output_lb_public_ip"></a> [lb\_public\_ip](#output\_lb\_public\_ip) | O IP público do Load Balancer. |
<!-- END_TF_DOCS -->