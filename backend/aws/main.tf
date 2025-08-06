terraform {
  required_version = "~> 1.12" # Exige uma versão do Terraform igual ou superior a 1.12.0, por exemplo.

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # Boa prática: Permite qualquer versão da série 6 (6.0, 6.1, 6.25, etc.)
    }
  }
}

provider "aws" {
  region = "us-east-1" # Região padrão para os recursos AWS (N. Virginia).   
}

#### RECURSOS DO BACKEND ####
#### Bucket S3 para guardar os arquivos de estado do Terraform ####

resource "aws_s3_bucket" "terraform_state" {
  bucket = "alissonlima-tcc-tfstate-backend-2025" # É o nome da nossa bucket, ele deve ser único em todo o mundo (boa prática inserir um indentificador pessoal).

  ### O parâmetro abaixo garante proteção contra um 'terraform destroy' acidental, que apagaria nosso bucket.

  lifecycle {
    prevent_destroy = true
  }
}

### Aqui é criado uma tabela DynamoDB para travar o arquivo de estado (terraform-state) durante a execução.
### Isso é importante para evitar que duas execuções do Terraform tentem modificar o estado ao mesmo tempo, o que poderia causar corrupção de dados.
### O nome da tabela deve ser único na região, então é uma boa prática incluir um identificador pessoal no nome.

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "alissonlima-tcc-terraform-locks"
  billing_mode = "PAY_PER_REQUEST" # Modo de cobrança mais econômico para baixo uso, será cobrado somente quando for solicitado.
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

/* O intuito deste arquivo main.tf é criar os recursos necessários para o backend remoto do Terraform na AWS.
   Esses recursos incluem um bucket S3 para armazenar o arquivo de estado do Terraform (.tfstate) e uma tabela DynamoDB para gerenciar os bloqueios de estado.
   Isso garante que o estado da infraestrutura seja armazenado de forma centralizada e segura, e que múltiplas execuções do Terraform (por exemplo, por um desenvolvedor e por um pipeline de CI/CD) não corrompam o estado ao tentar modificá-lo simultaneamente.
   É a prática fundamental para trabalho em equipe e automação robusta.
*/
