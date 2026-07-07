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
| [aws_instance.app_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.db_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_volume_attachment.db_data_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | ID da Amazon Machine Image (AMI) Ubuntu para os servidores. | `string` | n/a | yes |
| <a name="input_app_server_count"></a> [app\_server\_count](#input\_app\_server\_count) | O número de servidores de aplicação a serem criados (Escalabilidade). | `number` | `1` | no |
| <a name="input_db_server_availability_zone"></a> [db\_server\_availability\_zone](#input\_db\_server\_availability\_zone) | A Zona de Disponibilidade para o servidor de banco, necessária para alinhar com o volume EBS. | `string` | n/a | yes |
| <a name="input_db_volume_id"></a> [db\_volume\_id](#input\_db\_volume\_id) | ID do volume EBS a ser anexado ao servidor de banco de dados. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Nome do ambiente (teste, homol, prod) para composição dos nomes. | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Tipo da instância EC2 para os servidores do ambiente (Ex: t3.micro). | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Nome do par de chaves EC2 para acesso SSH. | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | LISTA de IDs das sub-redes privadas onde os servidores serão criados. | `list(string)` | n/a | yes |
| <a name="input_sg_application_id"></a> [sg\_application\_id](#input\_sg\_application\_id) | ID do Security Group unificado para a aplicação. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Um mapa de tags para ser aplicado nos recursos. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_app_server_ids"></a> [app\_server\_ids](#output\_app\_server\_ids) | Lista de IDs das instâncias de aplicação (Necessário para o Target Group do Load Balancer). |
| <a name="output_app_server_private_ips"></a> [app\_server\_private\_ips](#output\_app\_server\_private\_ips) | Lista de IPs privados das instâncias (Necessário para o inventário dinâmico do Ansible via Bastion). |
| <a name="output_db_server_availability_zone"></a> [db\_server\_availability\_zone](#output\_db\_server\_availability\_zone) | Zona de Disponibilidade do banco (Utilizado para garantir paridade no anexo de volumes). |
| <a name="output_db_server_id"></a> [db\_server\_id](#output\_db\_server\_id) | ID da instância EC2 do servidor de banco de dados. |
| <a name="output_db_server_private_ip"></a> [db\_server\_private\_ip](#output\_db\_server\_private\_ip) | Endereço IP privado do servidor de banco de dados. |
<!-- END_TF_DOCS -->