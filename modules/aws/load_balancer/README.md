<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.80.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_server_ids"></a> [app\_server\_ids](#input\_app\_server\_ids) | Lista de IDs das instâncias EC2 de aplicação para registro no Target Group. | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Nome do ambiente (ex: teste, homol, prod) para composição dos nomes dinâmicos. | `string` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Lista de IDs das sub-redes públicas (O ALB exige pelo menos duas subnets em AZs diferentes). | `list(string)` | n/a | yes |
| <a name="input_sg_alb_id"></a> [sg\_alb\_id](#input\_sg\_alb\_id) | ID do Security Group para o Load Balancer (Permite tráfego das portas 80/443). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Um mapa de tags para ser aplicado nos recursos do Load Balancer. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID da VPC onde o Load Balancer e o Target Group serão criados. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | ARN do Load Balancer para fins de monitoramento e métricas. |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | Nome DNS do ALB. Use este valor para criar o CNAME na Cloudflare (Ex: app.alissonlima.dev.br -> alb-tcc...). |
| <a name="output_alb_zone_id"></a> [alb\_zone\_id](#output\_alb\_zone\_id) | ID da Hosted Zone do ALB (Necessário caso decida usar o Route 53 no futuro). |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN do Target Group (Útil para integração com Auto Scaling ou logs de auditoria). |
<!-- END_TF_DOCS -->