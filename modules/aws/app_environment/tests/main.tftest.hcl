mock_provider "aws" {}

variables {
  environment                 = "teste"
  private_subnet_ids          = ["subnet-0111111111111111a", "subnet-0222222222222222b"]
  sg_application_id           = "sg-0333333333333333c"
  instance_type               = "t3.micro"
  ami_id                      = "ami-0444444444444444d"
  key_name                    = "tcc-keypair"
  db_volume_id                = "vol-0555555555555555e"
  db_server_availability_zone = "us-east-1a"
  app_server_count            = 2
  tags                        = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

run "app_server_count_matches_input" {
  command = plan

  assert {
    condition     = length(aws_instance.app_server) == var.app_server_count
    error_message = "Número de servidores de aplicação não corresponde a var.app_server_count"
  }
}

run "instances_use_imdsv2_and_expected_type" {
  command = plan

  assert {
    condition     = alltrue([for i in aws_instance.app_server : i.metadata_options[0].http_tokens == "required"])
    error_message = "Servidores de app devem forçar IMDSv2 (http_tokens = required)"
  }

  assert {
    condition     = aws_instance.db_server.metadata_options[0].http_tokens == "required"
    error_message = "Servidor de banco deve forçar IMDSv2 (http_tokens = required)"
  }

  assert {
    condition     = alltrue([for i in aws_instance.app_server : i.instance_type == var.instance_type])
    error_message = "Tipo de instância dos servidores de app não corresponde à variável de entrada"
  }
}
