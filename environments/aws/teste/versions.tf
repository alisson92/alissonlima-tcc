terraform {
  required_version = "~> 1.12"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Forçando o uso de uma versão estável e madura da série 5.x
      version = "~> 5.0"
    }
  }
}
