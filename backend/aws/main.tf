# =====================================================================
# BACKEND/AWS/MAIN.TF - BOOTSTRAP DO ESTADO REMOTO (S3 + DYNAMODB)
# =====================================================================

terraform {
  required_version = "~> 1.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0" # Mantendo a paridade com o restante do projeto
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Bucket S3 para o Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "alissonlima-tcc-terraform-state"

  lifecycle {
    prevent_destroy = true # Proteção vital para não perder o histórico do TCC
  }

  tags = {
    Name        = "Terraform State Storage"
    Project     = "TCC-AlissonLima"
    Environment = "Global"
  }
}

# 2. Habilitar Versionamento (Boa prática fundamental de DevOps)
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Criptografia do Bucket (Segurança de Dados)
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Tabela DynamoDB para State Locking (Evita corrupção de estado)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "alissonlima-tcc-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Project     = "TCC-AlissonLima"
    Environment = "Global"
  }
}