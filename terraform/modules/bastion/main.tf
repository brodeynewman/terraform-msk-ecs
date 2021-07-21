data "aws_ami" "bastion" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs*"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "bastion" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port = 22
    protocol = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "deployer-one"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCy64BJCXd3q/QroEDUTIGVN1zCz/7vcGKG2kIVgUq1FSBAJwa9ouQ8dpw+YGpzX6NqWdk9QEWIlMNJOke2fRgTjo+qXQZkN9Cv/ZgKMtaayZ9TbSeCFPqRtfQLQ75ZnrsKCmvwKssO+pYeXUrsF3RHqc+r4kNprlSQ0c3IHVozkJQrmwFvaUA6LORUuCwkKj6xMVZRpDfQeeGyvx2HW+zorqKI5GU6GhvoNL/oyjx46ZqBwD/2cQsD9V5POtmVaUeAIBuGch5Zy4B8y0vO3e14/ZpyxyJvUsnKpsShC+pFWdtFf0cyfsCN3nscbYdsqSPArxDabf6y34V3RD/aj7/wH7yA6+tPs0zhZZdmQY4cJPWvpuupOi9wWpgwFlngsIJtT5t2t4G5ucUoocyXD3O4J2zfjJvRSRj5hWQRrUihp7ZQx2ypAdhUuGKFpcGtSYekjaawYaxGkJcWpgDBa1pxkkbLx2vjgKNflm7lfNE35ZMDetH1sUzkn83TmKiKqA8= brodeynewman@gmail.com"
}

resource "aws_instance" "bastion" {
    ami                         = data.aws_ami.bastion.id
    instance_type               = "t2.micro"
    iam_instance_profile        = aws_iam_instance_profile.default.name
    key_name                    = module.key_pair.key_pair_key_name
    vpc_security_group_ids      = [aws_security_group.bastion.id]
    user_data                   = data.template_file.user_data.rendered 
    subnet_id                   = var.public_subnet_id
    source_dest_check           = false
    associate_public_ip_address = true

    tags = {
      name = "Bastion host"
    }
}