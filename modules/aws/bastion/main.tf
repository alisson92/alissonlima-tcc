resource "aws_instance" "bastion_host" {
  ami           = var.ami_id
  instance_type = "t3.micro" # Pode ser a menor instância possível
  subnet_id     = var.public_subnet_id # <-- Importante: criado na sub-rede pública
  key_name      = var.key_name
  vpc_security_group_ids = [var.sg_bastion_id]

  tags = {
    Name = "bastion-host-teste"
  }
}