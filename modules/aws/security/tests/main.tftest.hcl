mock_provider "aws" {}

variables {
  vpc_id      = "vpc-0123456789abcdef0"
  environment = "teste"
  my_ip       = "203.0.113.10/32"
  tags        = { Project = "tcc" }
}

run "plans_successfully" {
  command = plan
}

# Invariante de least-privilege documentado no CLAUDE.md: o tier de
# aplicação deve receber tráfego do ALB e do Bastion referenciando o
# Security Group de origem por ID, nunca por um CIDR aberto.
run "app_ingress_references_source_sg_not_cidr" {
  command = apply

  assert {
    condition     = aws_security_group_rule.app_ingress_alb.source_security_group_id != null
    error_message = "Ingress do app tier vindo do ALB deve referenciar o SG do ALB por ID, não um CIDR aberto"
  }

  assert {
    condition     = aws_security_group_rule.app_ingress_bastion.source_security_group_id != null
    error_message = "Ingress SSH do app tier vindo do Bastion deve referenciar o SG do Bastion por ID, não um CIDR aberto"
  }
}

run "bastion_ssh_scoped_to_owner_ip" {
  command = plan

  assert {
    condition     = aws_security_group_rule.bastion_ssh_owner.cidr_blocks == tolist([var.my_ip])
    error_message = "SSH do Bastion deve ficar restrito ao IP do proprietário, não a 0.0.0.0/0"
  }
}
