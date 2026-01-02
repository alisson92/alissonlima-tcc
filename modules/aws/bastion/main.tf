# ==========================================
# INSTÂNCIA EC2: BASTION HOST (PONTO DE SALTO)
# ==========================================
resource "aws_instance" "bastion_host" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.sg_bastion_id]
  associate_public_ip_address = true # Garante IP público para o acesso inicial

  # Garante que a instância use o usuário padrão 'ubuntu' para paridade multicloud
  tags = merge(var.tags, {
    Name = "bastion-tcc-${var.environment}"
  })

  # Root Block Device: Padronização de disco
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    
    tags = merge(var.tags, {
      Name = "disk-bastion-tcc-${var.environment}"
    })
  }
}