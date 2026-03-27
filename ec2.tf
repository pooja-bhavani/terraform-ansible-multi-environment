data "aws_ami" "os_image" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/*amd64*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "terra-automate-key"
  public_key = file("terra-key.pub")
}

resource "aws_default_vpc" "default" {
}

resource "aws_security_group" "allow_user_to_connect" {
  name        = "allow TLS"
  description = "Allow user to connect"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "port 22 allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 80 allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 443 allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysecurity"
  }
}

# user_data is the modern approach for bootstrapping EC2 instances.
# Provisioners (remote-exec, local-exec) are considered an anti-pattern
# because they break the declarative model and are not stored in state.
# Prefer user_data, cloud-init, or configuration management tools (Ansible).
resource "aws_instance" "testinstance" {
  ami                    = data.aws_ami.os_image.id
  instance_type          = var.my_environment == "prd" ? "t2.medium" : "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_user_to_connect.id]
  user_data              = file("${path.module}/script.sh")

  tags = {
    Name = "Terra-Automate"
  }

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }
}
