## Motivação

O Bastion Host é o único recurso do ambiente com IP público e regra de
ingresso SSH — todo acesso administrativo a app/DB passa por ele via SSH
Agent Forwarding (ver `docs/ACESSOS.md`). O SG que o protege (`modules/aws/security`)
só libera a porta 22 para o IP fixo do operador e, durante execuções do
pipeline, para o IP do runner do GitHub Actions, aberto e fechado
just-in-time (ver seção "CI/CD pipeline shape" do `CLAUDE.md`).

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
| [aws_instance.bastion_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | ID da AMI Ubuntu para o Bastion Host. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Nome do ambiente (ex: teste, homol, prod) para composição dos nomes. | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Nome do par de chaves EC2 para acesso SSH. | `string` | n/a | yes |
| <a name="input_public_subnet_id"></a> [public\_subnet\_id](#input\_public\_subnet\_id) | ID da sub-rede pública onde o Bastion será criado. | `string` | n/a | yes |
| <a name="input_sg_bastion_id"></a> [sg\_bastion\_id](#input\_sg\_bastion\_id) | ID do Security Group para o Bastion Host. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Um mapa de tags para ser aplicado aos recursos do Bastion. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_instance_id"></a> [bastion\_instance\_id](#output\_bastion\_instance\_id) | O ID da instância do Bastion Host. |
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | O endereço IP público do Bastion Host (Necessário para o DNS e para o ProxyCommand do Ansible). |
<!-- END_TF_DOCS -->