data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "Bastion security group"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data/amazon-linux.sh")

  vars = {
    user_data   = ""
    ssm_enabled = true
    ssh_user    = "ec2-user"
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.bastion.id
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.default.name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  user_data                   = data.template_file.user_data.rendered
  subnet_id                   = var.public_subnet_id

  tags = {
    name = "Bastion host"
  }
}