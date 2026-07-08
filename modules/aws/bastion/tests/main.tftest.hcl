mock_provider "aws" {}

variables {
  public_subnet_id = "subnet-0111111111111111a"
  sg_bastion_id    = "sg-0222222222222222b"
  ami_id           = "ami-0333333333333333c"
  key_name         = "tcc-keypair"
  environment      = "teste"
  tags             = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

run "bastion_has_public_ip_and_imdsv2" {
  command = plan

  assert {
    condition     = aws_instance.bastion_host.associate_public_ip_address == true
    error_message = "Bastion precisa de IP público para ser o único ponto de entrada SSH"
  }

  assert {
    condition     = aws_instance.bastion_host.metadata_options[0].http_tokens == "required"
    error_message = "Bastion deve forçar IMDSv2 (http_tokens = required)"
  }

  assert {
    condition     = aws_instance.bastion_host.root_block_device[0].encrypted == true
    error_message = "Disco raiz do Bastion deve estar criptografado"
  }
}
