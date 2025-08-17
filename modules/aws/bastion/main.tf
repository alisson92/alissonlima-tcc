resource "aws_instance" "bastion_host" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.sg_bastion_id]

  tags = merge(var.tags, {
    Name = "bastion-host-${var.environment}"
  })
}

# Adicione este recurso para criar o registro DNS
resource "aws_route53_record" "bastion_dns" {
  zone_id = var.zone_id
  name    = "bastion-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.bastion_host.public_ip]
}