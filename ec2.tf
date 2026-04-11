# Key Value pair

resource "aws_key_pair" "my_key_pair" {
  key_name   = "${terraform.workspace}-terra-key"
  public_key = file("terra-automate-key.pub")
}

# VPC Default

resource "aws_default_vpc" "default" {}

# Security Group 

resource "aws_security_group" "my_security_group" {
  name        = "${terraform.workspace}-terra-security-group"
  vpc_id      = aws_default_vpc.default.id
  description = "Security group"
}

# Inbound & Outbount port rules

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.my_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"    # semantically equivalent to all ports 
}

# EC2 instance

resource "aws_instance" "my_instance" {
  count = local.current.ec2

  ami           = var.ami_id
  instance_type = var.instance_type

  key_name = aws_key_pair.my_key_pair.key_name

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.my_security_group.id]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name        = "${terraform.workspace}-ec2-${count.index}"
    Environment = terraform.workspace
  }
}