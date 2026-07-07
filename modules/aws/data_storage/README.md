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
| [aws_ebs_volume.db_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_az"></a> [az](#input\_az) | A Zona de Disponibilidade onde o volume será criado (Deve ser a mesma da instância EC2). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Nome do ambiente (ex: teste, homol, prod) para composição das tags. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Um mapa de tags para ser aplicado aos recursos de armazenamento. | `map(string)` | `{}` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | O tamanho do volume EBS em GB (Ex: 10, 20, 50). | `number` | `8` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_volume_id"></a> [volume\_id](#output\_volume\_id) | O ID do volume EBS criado. Este valor é injetado no módulo app\_environment para o anexo físico ao banco de dados. |
<!-- END_TF_DOCS -->