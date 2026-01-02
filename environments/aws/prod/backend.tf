# =====================================================================
# ENVIRONMENTS/PROD/BACKEND.TF - ESTADO REMOTO SEGURO (AWS S3)
# =====================================================================

terraform {
  backend "s3" {
    # Nome padronizado e atemporal para o bucket de estado
    bucket         = "alissonlima-tcc-terraform-state"
    
    # Caminho organizado para isolar o estado deste ambiente específico
    key            = "aws/prod/terraform.tfstate"
    
    region         = "us-east-1"
    
    # Tabela DynamoDB para controle de trava (Locking)
    dynamodb_table = "alissonlima-tcc-terraform-state-lock"
    
    # Garante que o arquivo de estado seja criptografado em repouso
    encrypt        = true
  }
}