terraform {
  required_version = "~> 1.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.31.0" # Travando em uma versão ultra-estável
    }
  }
}
