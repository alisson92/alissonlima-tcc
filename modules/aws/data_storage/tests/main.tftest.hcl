mock_provider "aws" {}

variables {
  environment = "teste"
  az          = "us-east-1a"
  volume_size = 20
  tags        = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

run "volume_matches_input_size_and_az" {
  command = plan

  assert {
    condition     = aws_ebs_volume.db_data.size == var.volume_size
    error_message = "Tamanho do volume EBS não corresponde à variável de entrada"
  }

  assert {
    condition     = aws_ebs_volume.db_data.availability_zone == var.az
    error_message = "AZ do volume EBS deve coincidir com a variável de entrada, para alinhar com a instância EC2"
  }
}

run "volume_is_encrypted" {
  command = plan

  assert {
    condition     = aws_ebs_volume.db_data.encrypted == true
    error_message = "Volume de dados do banco deve estar criptografado"
  }
}
