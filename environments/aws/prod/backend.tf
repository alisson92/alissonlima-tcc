terraform {
  backend "s3" {
    bucket         = "alissonlima-tcc-tfstate-backend-2025"
    key            = "environments/aws/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "alissonlima-tcc-terraform-locks"
    encrypt        = true
  }
}
